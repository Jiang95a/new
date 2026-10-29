package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.common.ErrorCode;
import com.campus.server.common.PageDocumentValidator;
import com.campus.server.dto.Dtos;
import com.campus.server.entity.MiscEntities.ActivityEventEntity;
import com.campus.server.entity.PageVersionEntity;
import com.campus.server.entity.ProjectEntity;
import com.campus.server.entity.TemplateEntity;
import com.campus.server.mapper.PageVersionMapper;
import com.campus.server.mapper.ProjectMapper;
import com.campus.server.mapper.SubmissionMapper;
import com.campus.server.mapper.TemplateMapper;
import com.campus.server.security.CurrentUser;
import com.campus.server.support.Ids;
import com.campus.server.support.JsonUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;

/**
 * 项目 CRUD、草稿保存（乐观锁）、版本、发布、公开读取。
 *
 * <p>所有方法都会校验「这个项目是不是当前用户的」，越权统一返回 403 而不是 404 ——
 * 便于前端排查，但会暴露项目是否存在。V1 接受这个取舍（PRD 也要求越权检查可见）。
 */
@Service
public class ProjectService {

    private final ProjectMapper projectMapper;
    private final PageVersionMapper versionMapper;
    private final TemplateMapper templateMapper;
    private final SubmissionMapper submissionMapper;
    private final PageDocumentValidator documentValidator;
    private final DocumentNormalizer normalizer;
    private final com.campus.server.config.AppProperties props;

    public ProjectService(ProjectMapper projectMapper, PageVersionMapper versionMapper,
                          TemplateMapper templateMapper, SubmissionMapper submissionMapper,
                          PageDocumentValidator documentValidator, DocumentNormalizer normalizer,
                          com.campus.server.config.AppProperties props) {
        this.projectMapper = projectMapper;
        this.versionMapper = versionMapper;
        this.templateMapper = templateMapper;
        this.submissionMapper = submissionMapper;
        this.documentValidator = documentValidator;
        this.normalizer = normalizer;
        this.props = props;
    }

    // ================================================================ 查询

    public Dtos.PagedResultHolder<Dtos.ProjectDto> list(String q, String status, String sort,
                                                        int page, int pageSize) {
        String ownerId = CurrentUser.require().userId();
        int safePage = Math.max(page, 1);
        int safeSize = Math.min(Math.max(pageSize, 1), 100);
        long total = projectMapper.countSearch(ownerId, q, status);
        List<ProjectEntity> rows = total == 0
                ? List.of()
                : projectMapper.search(ownerId, q, status, sort, safeSize, (safePage - 1) * safeSize);
        List<Dtos.ProjectDto> data = rows.stream().map(this::toDto).toList();
        return new Dtos.PagedResultHolder<>(data, new Dtos.PageMeta(safePage, safeSize, total));
    }

    public Dtos.ProjectDto get(String projectId) {
        return toDto(loadOwned(projectId));
    }

    // ================================================================ 创建

    @Transactional
    public Dtos.ProjectDto create(Dtos.CreateProjectRequest request) {
        String ownerId = CurrentUser.require().userId();
        JsonNode document = request.initialDocument();

        if (document != null && !document.isNull()) {
            documentValidator.validateOrThrow(document);
        } else if (request.templateId() != null && !request.templateId().isBlank()) {
            TemplateEntity template = templateMapper.findById(request.templateId());
            if (template == null) {
                throw BizException.notFound("模板不存在");
            }
            document = buildDocumentFromTemplate(template, request.title());
        } else {
            throw BizException.invalid("缺少 initialDocument，也没给 templateId");
        }

        ProjectEntity project = new ProjectEntity();
        project.setId(Ids.uuid());
        project.setOwnerId(ownerId);
        project.setTemplateId(request.templateId());
        project.setTitle(request.title().trim());
        project.setDescription(request.description());
        project.setStatus("draft");
        project.setDraftDocument(document);
        project.setDraftRevision(0L);
        project.setPublishSettings(JsonUtil.mapper().createObjectNode());
        projectMapper.insert(project);
        return toDto(projectMapper.findById(project.getId()));
    }

    @Transactional
    public Dtos.ProjectDto duplicate(String projectId, Dtos.DuplicateProjectRequest request) {
        ProjectEntity source = loadOwned(projectId);
        ProjectEntity copy = new ProjectEntity();
        copy.setId(Ids.uuid());
        copy.setOwnerId(source.getOwnerId());
        copy.setTemplateId(source.getTemplateId());
        copy.setTitle(request.title().trim());
        copy.setDescription(source.getDescription());
        copy.setStatus("draft");
        copy.setDraftDocument(source.getDraftDocument());
        copy.setDraftRevision(0L);
        copy.setPublishSettings(JsonUtil.mapper().createObjectNode());

        // 副本要换 slug，否则公开页会打架
        ObjectNode doc = source.getDraftDocument() == null
                ? JsonUtil.mapper().createObjectNode()
                : source.getDraftDocument().deepCopy();
        doc.remove("published");
        doc.put("slug", uniqueSlug(Ids.slugify(request.title()), null));
        copy.setDraftDocument(doc);

        projectMapper.insert(copy);
        return toDto(projectMapper.findById(copy.getId()));
    }

    // ================================================================ 修改 / 删除

    public Dtos.ProjectDto update(String projectId, Dtos.UpdateProjectRequest request) {
        ProjectEntity project = loadOwned(projectId);
        String title = request.title() == null || request.title().isBlank()
                ? project.getTitle()
                : request.title().trim();
        if (title.length() > 160) {
            throw BizException.invalid("标题最多 160 字");
        }
        projectMapper.updateBasic(projectId, title, request.description());
        return toDto(projectMapper.findById(projectId));
    }

    public void delete(String projectId) {
        loadOwned(projectId);
        projectMapper.softDelete(projectId);
    }

    // ================================================================ 草稿

    public Dtos.DraftDto getDraft(String projectId) {
        ProjectEntity project = loadOwned(projectId);
        return new Dtos.DraftDto(project.getDraftRevision(), project.getDraftDocument(),
                Ids.iso(project.getUpdatedAt()));
    }

    /**
     * 乐观锁保存：baseRevision 与服务端不一致 → 409。
     * 前端拿到 409 后应提示「别人改过，先刷新」，而不是覆盖。
     */
    @Transactional
    public Dtos.SaveDraftResult saveDraft(String projectId, Dtos.SaveDraftRequest request) {
        ProjectEntity project = loadOwned(projectId);
        if (request.document() == null || request.document().isNull()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "页面文档不能为空");
        }
        documentValidator.validateOrThrow(request.document());

        long base = request.baseRevision() == null ? project.getDraftRevision() : request.baseRevision();
        if (request.baseRevision() != null && request.baseRevision() < 0) {
            throw BizException.invalid("baseRevision 不能为负");
        }
        long next = base + 1;
        int updated = projectMapper.updateDraftWithRevision(projectId, request.document(), base, next);
        if (updated == 0) {
            throw new BizException(ErrorCode.REVISION_CONFLICT,
                    "文档已被修改，当前服务端版本是 " + project.getDraftRevision() + "，请刷新后再保存");
        }
        return new Dtos.SaveDraftResult(next, Ids.nowIso());
    }

    // ================================================================ 版本

    public List<Dtos.VersionDto> listVersions(String projectId) {
        loadOwned(projectId);
        return versionMapper.listByProject(projectId).stream()
                .map(v -> new Dtos.VersionDto(v.getId(), v.getVersionNo(), v.getSource(),
                        v.getDocument(), Ids.iso(v.getCreatedAt())))
                .toList();
    }

    @Transactional
    public Dtos.VersionDto createVersion(String projectId, Dtos.CreateVersionRequest request) {
        ProjectEntity project = loadOwned(projectId);
        if (request.baseRevision() == null || request.baseRevision() != project.getDraftRevision()) {
            throw new BizException(ErrorCode.REVISION_CONFLICT,
                    "baseRevision 与服务端不一致（服务端 " + project.getDraftRevision() + "）");
        }
        String source = request.source() == null ? "manual" : request.source();
        if (!List.of("manual", "ai", "template").contains(source)) {
            throw BizException.invalid("source 只能是 manual / ai / template");
        }
        PageVersionEntity version = insertVersion(project, source);
        return new Dtos.VersionDto(version.getId(), version.getVersionNo(), version.getSource(),
                version.getDocument(), Ids.iso(version.getCreatedAt()));
    }

    // ================================================================ 发布 / 下线

    @Transactional
    public Dtos.PublishResult publish(String projectId, Dtos.PublishRequest request) {
        ProjectEntity project = loadOwned(projectId);
        JsonNode document;
        PageVersionEntity version;

        if (request != null && request.versionId() != null && !request.versionId().isBlank()) {
            version = versionMapper.findById(request.versionId());
            if (version == null || !version.getProjectId().equals(projectId)) {
                throw BizException.notFound("版本不存在");
            }
            document = version.getDocument();
        } else {
            documentValidator.validateOrThrow(project.getDraftDocument());
            normalizer.assertPublishable(project.getDraftDocument());
            version = insertVersion(project, "manual");
            document = version.getDocument();
        }

        String slug = resolveSlug(project, request == null ? null : request.slug());
        String publicUrl = props.getPublicBaseUrl().replaceAll("/+$", "") + "/" + slug;
        JsonNode publishSettings = (request != null && request.publishSettings() != null)
                ? request.publishSettings()
                : (project.getPublishSettings() == null
                   ? JsonUtil.mapper().createObjectNode() : project.getPublishSettings());

        projectMapper.updatePublish(projectId, "published", slug, version.getId(), publishSettings);

        String publishedAt = Ids.iso(version.getCreatedAt());
        return new Dtos.PublishResult(slug, publicUrl, version.getId(),
                publishedAt == null ? Ids.nowIso() : publishedAt);
    }

    @Transactional
    public void unpublish(String projectId) {
        loadOwned(projectId);
        projectMapper.markUnpublished(projectId);
    }

    // ================================================================ 公开读取（不需要登录）

    public Dtos.PublicActivityDto getPublic(String slug, boolean countView) {
        ProjectEntity project = projectMapper.findByPublicSlug(slug);
        if (project == null || !"published".equals(project.getStatus())) {
            throw BizException.notFound("活动不存在或未发布");
        }
        JsonNode document;
        if (project.getPublishedVersionId() != null) {
            PageVersionEntity version = versionMapper.findById(project.getPublishedVersionId());
            document = version == null ? project.getDraftDocument() : version.getDocument();
        } else {
            document = project.getDraftDocument();
        }

        if (countView) {
            ActivityEventEntity event = new ActivityEventEntity();
            event.setProjectId(project.getId());
            event.setEventType("public_page_view");
            event.setMetadata(JsonUtil.mapper().createObjectNode());
            // 埋点失败不能影响浏览
            try {
                miscMapper.insertEvent(event);
            } catch (RuntimeException ignored) {
                // ignore
            }
        }

        String publicStatus = publicStatus(project);
        return new Dtos.PublicActivityDto(slug, project.getTitle(), publicStatus,
                document, project.getPublishSettings());
    }

    /** 公开页的提交状态：published / closed / full / unpublished。 */
    public String publicStatus(ProjectEntity project) {
        if (!"published".equals(project.getStatus())) {
            return "unpublished";
        }
        JsonNode settings = project.getPublishSettings();
        long now = System.currentTimeMillis();
        if (settings != null && !settings.isNull()) {
            long closesAt = settings.path("closesAt").asLong(0);
            if (closesAt > 0 && now > closesAt) {
                return "closed";
            }
            long opensAt = settings.path("opensAt").asLong(0);
            if (opensAt > 0 && now < opensAt) {
                return "closed";
            }
            long max = settings.path("maxSubmissions").asLong(0);
            if (max > 0 && submissionMapper.countValid(project.getId()) >= max) {
                return "full";
            }
        }
        return "published";
    }

    // ================================================================ 内部

    public ProjectEntity loadOwned(String projectId) {
        CurrentUser current = CurrentUser.require();
        ProjectEntity project = projectMapper.findById(projectId);
        if (project == null) {
            throw BizException.notFound("项目不存在");
        }
        if (!project.getOwnerId().equals(current.userId())) {
            throw BizException.forbidden("这不是你的项目");
        }
        return project;
    }

    private Dtos.ProjectDto toDto(ProjectEntity project) {
        long submissions = submissionMapper.countValid(project.getId());
        String publicUrl = project.getPublicSlug() == null ? null
                : props.getPublicBaseUrl().replaceAll("/+$", "") + "/" + project.getPublicSlug();
        return new Dtos.ProjectDto(
                project.getId(),
                project.getTitle(),
                project.getDescription(),
                project.getStatus(),
                project.getDraftRevision() == null ? 0 : project.getDraftRevision(),
                project.getPublicSlug(),
                publicUrl,
                project.getPublishedVersionId(),
                submissions,
                Ids.iso(project.getCreatedAt()),
                Ids.iso(project.getUpdatedAt()),
                project.getDraftDocument()
        );
    }

    private String resolveSlug(ProjectEntity project, String requested) {
        String candidate = (requested == null || requested.isBlank())
                ? (project.getPublicSlug() != null ? project.getPublicSlug() : Ids.slugify(project.getTitle()))
                : requested.trim().toLowerCase(Locale.ROOT);
        if (!candidate.matches("^[a-z0-9]+(-[a-z0-9]+)*$")) {
            throw BizException.invalid("slug 只能是小写字母、数字和连字符");
        }
        if (projectMapper.countBySlug(candidate, project.getId()) > 0) {
            throw new BizException(ErrorCode.SLUG_CONFLICT, "该访问路径已被占用: " + candidate);
        }
        return candidate;
    }

    private String uniqueSlug(String base, String excludeId) {
        String candidate = (base == null || base.isBlank()) ? Ids.slugify("activity") : base;
        if (projectMapper.countBySlug(candidate, excludeId) == 0) {
            return candidate;
        }
        for (int i = 2; i < 50; i++) {
            String next = candidate + "-" + i;
            if (projectMapper.countBySlug(next, excludeId) == 0) {
                return next;
            }
        }
        return candidate + "-" + Ids.randomToken(6);
    }

    /** 插入新版本号（在并发下靠唯一索引兜底）。 */
    private PageVersionEntity insertVersion(ProjectEntity project, String source) {
        int next = versionMapper.maxVersionNo(project.getId()) + 1;
        PageVersionEntity version = new PageVersionEntity();
        version.setId(Ids.uuid());
        version.setProjectId(project.getId());
        version.setVersionNo(next);
        version.setDocument(project.getDraftDocument());
        version.setSource(source);
        version.setCreatedBy(CurrentUser.require().userId());
        try {
            versionMapper.insert(version);
        } catch (DuplicateKeyException ex) {
            throw new BizException(ErrorCode.REVISION_CONFLICT, "版本号冲突，请重试");
        }
        return versionMapper.findById(version.getId());
    }

    private JsonNode buildDocumentFromTemplate(TemplateEntity template, String title) {
        JsonNode source = template.getDocument();
        if (source == null || source.isNull()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID,
                    "模板 " + template.getCode() + " 的 document 是空的");
        }
        // 模板表里存的是「外层包了一层」的结构：{intent, reason, theme, title, pages:[...]}，
        // 而真正要落进 projects.draft_document 的是里面那个 Doc 本体。
        // 早期直接 doc.setAll(source) 会把整个壳塞进 pages[0]，页面就全乱了 —— 必须只取内层。
        JsonNode inner = source.get("document");
        JsonNode doc = (inner != null && inner.isObject()) ? inner : source;

        if (!doc.hasNonNull("title")) {
            ((ObjectNode) doc).put("title", title);
        }
        if (!doc.has("pages") || !doc.get("pages").isArray() || doc.get("pages").isEmpty()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID,
                    "模板 " + template.getCode() + " 的 document 里没有 pages");
        }
        return fillIds(doc.deepCopy());
    }

    /**
     * 模板里的页面和区块是「配方」，没有 id：id 是运行时由编辑器生成的。
     * 但 schema 要求 page.id / block.id 必填（前端 createBlock 也会补），
     * 所以模板实例化时要在这里补齐，否则发布时会被校验器打回 422。
     */
    private JsonNode fillIds(JsonNode doc) {
        JsonNode pages = doc.get("pages");
        for (JsonNode page : pages) {
            if (page instanceof ObjectNode pageNode) {
                if (!pageNode.hasNonNull("id") || pageNode.get("id").asText().isBlank()) {
                    pageNode.put("id", "pg-" + Ids.uuid());
                }
                JsonNode blocks = pageNode.get("blocks");
                if (blocks != null && blocks.isArray()) {
                    for (JsonNode block : blocks) {
                        if (block instanceof ObjectNode blockNode) {
                            if (!blockNode.hasNonNull("id") || blockNode.get("id").asText().isBlank()) {
                                blockNode.put("id", "blk-" + Ids.uuid());
                            }
                            if (!blockNode.has("props") || blockNode.get("props").isNull()) {
                                blockNode.set("props", JsonUtil.mapper().createObjectNode());
                            }
                        }
                    }
                }
            }
        }
        return doc;
    }

    @org.springframework.beans.factory.annotation.Autowired
    private com.campus.server.mapper.MiscMapper miscMapper;
}
