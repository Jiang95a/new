package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.common.ErrorCode;
import com.campus.server.dto.Dtos;
import com.campus.server.entity.FormSubmissionEntity;
import com.campus.server.entity.MiscEntities.ActivityEventEntity;
import com.campus.server.entity.ProjectEntity;
import com.campus.server.mapper.MiscMapper;
import com.campus.server.mapper.ProjectMapper;
import com.campus.server.mapper.SubmissionMapper;
import com.campus.server.security.CurrentUser;
import com.campus.server.support.Ids;
import com.campus.server.support.JsonUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 公开页提交 + 组织者查看提交列表。
 *
 * <p>幂等：前端每次进表单生成一个 idempotencyKey（放在请求体里），
 * 后端用 (project_id, idempotency_key) 唯一索引兜底，重复提交返回同一条记录而不是报错。
 */
@Service
public class SubmissionService {

    private final SubmissionMapper submissionMapper;
    private final ProjectMapper projectMapper;
    private final MiscMapper miscMapper;
    private final ProjectService projectService;
    private final DocumentNormalizer normalizer;

    public SubmissionService(SubmissionMapper submissionMapper, ProjectMapper projectMapper,
                             MiscMapper miscMapper, ProjectService projectService,
                             DocumentNormalizer normalizer) {
        this.submissionMapper = submissionMapper;
        this.projectMapper = projectMapper;
        this.miscMapper = miscMapper;
        this.projectService = projectService;
        this.normalizer = normalizer;
    }

    // ================================================================ 公开提交

    @Transactional
    public Dtos.SubmissionResult submit(String slug, Dtos.SubmissionRequest request) {
        ProjectEntity project = projectMapper.findByPublicSlug(slug);
        if (project == null || !"published".equals(project.getStatus())) {
            throw BizException.notFound("活动不存在或未发布");
        }

        String status = projectService.publicStatus(project);
        if ("closed".equals(status)) {
            throw new BizException(ErrorCode.SUBMISSION_CLOSED, "活动已关闭，不再接受提交");
        }
        if ("full".equals(status)) {
            throw new BizException(ErrorCode.SUBMISSION_CLOSED, "报名人数已满");
        }

        String pageId = request.pageId();
        String formComponentId = request.formComponentId();
        if (pageId == null || pageId.isBlank() || formComponentId == null || formComponentId.isBlank()) {
            throw BizException.invalid("pageId 和 formComponentId 都不能为空");
        }

        JsonNode publishedDocument = project.getPublishedVersionId() == null
                ? project.getDraftDocument()
                : loadPublishedDocument(project);

        JsonNode answers = request.answers();
        if (answers == null || !answers.isObject()) {
            throw BizException.invalid("answers 必须是对象");
        }

        // 校验必填项（按发布出去的文档，而不是草稿）
        List<Map<String, Object>> required = normalizer.requiredFields(publishedDocument, pageId, formComponentId);
        List<String> missing = new ArrayList<>();
        for (Map<String, Object> field : required) {
            // 前端的答案 key 是 "<blockId>:<fieldId>"（web/src/views/PublicActivityView.vue:65），
            // 依次兜底再试 "<pageId>:<fieldId>" 和裸 fieldId，兼容手写调用和旧数据。
            String fieldId = String.valueOf(field.get("id"));
            JsonNode value = firstPresent(answers,
                    formComponentId + ":" + fieldId,
                    pageId + ":" + fieldId,
                    fieldId);
            boolean empty = value == null || value.isNull()
                    || (value.isTextual() && value.asText().isBlank())
                    || (value.isArray() && value.isEmpty());
            if (empty) {
                missing.add(String.valueOf(field.get("label")));
            }
        }
        if (!missing.isEmpty()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID,
                    "还有必填项没填", Map.of("missing", missing));
        }

        String rawKey = Ids.idempotencyKey(request.idempotencyKey());
        String idemKey = Ids.scopedIdempotencyKey(project.getId(), rawKey);

        FormSubmissionEntity existing = submissionMapper.findByIdempotencyKey(project.getId(), idemKey);
        if (existing != null) {
            return new Dtos.SubmissionResult(existing.getId(), existing.getStatus(),
                    Ids.iso(existing.getSubmittedAt()));
        }

        FormSubmissionEntity entity = new FormSubmissionEntity();
        entity.setId(Ids.uuid());
        entity.setProjectId(project.getId());
        entity.setVersionId(project.getPublishedVersionId());
        entity.setPageId(pageId);
        entity.setFormComponentId(formComponentId);
        entity.setAnswers(answers);
        entity.setIdempotencyKey(idemKey);
        entity.setSubmitterHash(Ids.randomToken(32));
        entity.setStatus("valid");

        try {
            submissionMapper.insert(entity);
        } catch (DuplicateKeyException ex) {
            // 并发下同时进来了两次，回读已有的那条，对前端依然是幂等的
            FormSubmissionEntity again = submissionMapper.findByIdempotencyKey(project.getId(), idemKey);
            if (again == null) {
                throw new BizException(ErrorCode.DUPLICATE_SUBMISSION, "重复提交");
            }
            return new Dtos.SubmissionResult(again.getId(), again.getStatus(), Ids.iso(again.getSubmittedAt()));
        }

        FormSubmissionEntity saved = submissionMapper.findByIdempotencyKey(project.getId(), idemKey);
        recordEvent(project.getId(), pageId, "submission_succeeded");
        return new Dtos.SubmissionResult(saved.getId(), saved.getStatus(), Ids.iso(saved.getSubmittedAt()));
    }

    // ================================================================ 组织者查看

    public Dtos.PagedResultHolder<Dtos.SubmissionDto> list(String projectId, String status,
                                                            int page, int pageSize) {
        projectService.loadOwned(projectId);
        int safePage = Math.max(page, 1);
        int safeSize = Math.min(Math.max(pageSize, 1), 200);
        long total = submissionMapper.count(projectId, status);
        List<FormSubmissionEntity> rows = total == 0
                ? List.of()
                : submissionMapper.page(projectId, status, safeSize, (safePage - 1) * safeSize);
        List<Dtos.SubmissionDto> data = rows.stream()
                .map(s -> new Dtos.SubmissionDto(s.getId(), s.getPageId(), s.getFormComponentId(),
                        s.getAnswers(), s.getStatus(), Ids.iso(s.getSubmittedAt())))
                .toList();
        return new Dtos.PagedResultHolder<>(data, new Dtos.PageMeta(safePage, safeSize, total));
    }

    /** 导出用：不分页，一次取全部（V1 上限一万条）。 */
    public List<FormSubmissionEntity> allForExport(String projectId) {
        projectService.loadOwned(projectId);
        return submissionMapper.page(projectId, null, 10000, 0);
    }

    // ================================================================ 内部

    private JsonNode loadPublishedDocument(ProjectEntity project) {
        JsonNode document = project.getDraftDocument();
        return document == null ? JsonUtil.mapper().createObjectNode() : document;
    }

    private void recordEvent(String projectId, String pageId, String type) {
        try {
            ActivityEventEntity event = new ActivityEventEntity();
            event.setProjectId(projectId);
            event.setPageId(pageId);
            event.setEventType(type);
            ObjectNode meta = JsonUtil.mapper().createObjectNode();
            meta.put("at", System.currentTimeMillis());
            event.setMetadata(meta);
            miscMapper.insertEvent(event);
        } catch (RuntimeException ignored) {
            // 埋点失败不影响主流程
        }
    }

    /** 只有项目拥有者能看到提交列表；这条在 Controller 里靠 CurrentUser 保证。 */
    public void assertOwner(String projectId) {
        projectService.loadOwned(projectId);
        CurrentUser.require();
    }

    /** 依次尝试几个 key，返回第一个非 null 的值。 */
    private JsonNode firstPresent(JsonNode answers, String... keys) {
        for (String key : keys) {
            JsonNode value = answers.get(key);
            if (value != null) {
                return value;
            }
        }
        return null;
    }
}
