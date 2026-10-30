package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.dto.Dtos;
import com.campus.server.entity.AiJobEntity;
import com.campus.server.entity.AiProposalEntity;
import com.campus.server.entity.ProjectEntity;
import com.campus.server.mapper.AiMapper;
import com.campus.server.security.CurrentUser;
import com.campus.server.support.Ids;
import com.campus.server.support.JsonUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Map;

/**
 * AI 相关能力。
 *
 * <p><b>分工</b>：真正的模型编排在 {@code agent/}（FastAPI，8000 端口），
 * 后端只负责 (1) 转调 agent 的 POST /chat，(2) 把生成的页面落成 ai_proposals 供人工「采用」。
 *
 * <p><b>降级是硬要求</b>：agent 不通或没配 Key 时，这里抛 503 AGENT_UNAVAILABLE，
 * 但绝不把异常抛成 500 把前端页面打挂 —— 前端会退到本地模板（{@code web/src/services/planner.ts}）。
 */
@Service
public class AiService {

    private static final Logger log = LoggerFactory.getLogger(AiService.class);

    private final AiMapper aiMapper;
    private final RestClient agentClient;

    @Autowired
    private ProjectService projectService;

    public AiService(AiMapper aiMapper, RestClient agentRestClient) {
        this.aiMapper = aiMapper;
        this.agentClient = agentRestClient;
    }

    // ================================================================ 转调 agent

    /** 透传一次 /chat。前端 AiPanel 也走这条。 */
    public JsonNode chat(String message, String threadId, String systemExtra) {
        if (message == null || message.isBlank()) {
            throw BizException.invalid("message 不能为空");
        }
        ObjectNode payload = JsonUtil.mapper().createObjectNode();
        payload.put("message", message);
        if (threadId != null && !threadId.isBlank()) {
            payload.put("thread_id", threadId);
        }
        if (systemExtra != null && !systemExtra.isBlank()) {
            payload.put("system_extra", systemExtra);
        }

        try {
            JsonNode response = agentClient.post()
                    .uri("/chat")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(JsonUtil.toJson(payload))
                    .retrieve()
                    .body(JsonNode.class);
            return response == null ? JsonUtil.mapper().createObjectNode() : response;
        } catch (RestClientException ex) {
            log.warn("调用 agent /chat 失败: {}", ex.getMessage());
            throw new com.campus.server.common.BizException(
                    com.campus.server.common.ErrorCode.AGENT_UNAVAILABLE,
                    "智能体暂时不可用，请先用手动方式搭建页面");
        }
    }

    /** 探活：GET {agent}/health，失败返回 false 而不抛异常。 */
    public boolean agentAlive() {
        try {
            JsonNode body = agentClient.get().uri("/health").retrieve().body(JsonNode.class);
            return body != null && body.path("ok").asBoolean(false);
        } catch (Exception ex) {
            return false;
        }
    }

    /** 海报解析统一经业务后端转发，前端不再直连 8000。 */
    public JsonNode extractPoster(String dataUrl, String imageUrl) {
        try {
            JsonNode response;
            if (imageUrl != null && !imageUrl.isBlank()) {
                response = agentClient.post()
                        .uri(uriBuilder -> uriBuilder.path("/poster/extract")
                                .queryParam("url", imageUrl)
                                .build())
                        .retrieve()
                        .body(JsonNode.class);
            } else {
                if (dataUrl == null || dataUrl.isBlank()) {
                    throw BizException.invalid("dataUrl 或 url 至少提供一个");
                }
                ObjectNode payload = JsonUtil.mapper().createObjectNode();
                payload.put("dataUrl", dataUrl);
                response = agentClient.post()
                        .uri("/poster/extract")
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(JsonUtil.toJson(payload))
                        .retrieve()
                        .body(JsonNode.class);
            }
            return response == null ? JsonUtil.mapper().createObjectNode() : response;
        } catch (BizException ex) {
            throw ex;
        } catch (RestClientException ex) {
            log.warn("调用 agent /poster/extract 失败: {}", ex.getMessage());
            throw new com.campus.server.common.BizException(
                    com.campus.server.common.ErrorCode.AGENT_UNAVAILABLE,
                    "海报识别暂时不可用，请手动填写活动信息");
        }
    }

    // ================================================================ 生成提案

    /**
     * 让 agent 按提示词生成一份 PageDocument 候选稿，落成 ai_proposals。
     * <b>不直接改项目草稿</b>——必须由用户在编辑器里点「采用」才会生效（人在环）。
     */
    @Transactional
    public Dtos.AiProposalDto generateFromPrompt(String projectId, String prompt,
                                                 long baseRevision, String clientRequestId) {
        String userId = CurrentUser.require().userId();
        projectService.loadOwned(projectId);

        // 同一次点击重发（前端连点、网络重试）直接返回原来那条提案
        if (clientRequestId != null && !clientRequestId.isBlank()) {
            AiJobEntity done = aiMapper.findLatestJobByClientRequest(userId, clientRequestId);
            if (done != null && "succeeded".equals(done.getStatus())) {
                AiProposalEntity existing = aiMapper.findProposal(done.getId());
                if (existing != null) {
                    return toProposalDto(existing);
                }
            }
        }
        if (prompt == null || prompt.isBlank()) {
            throw BizException.invalid("prompt 不能为空");
        }

        AiJobEntity job = new AiJobEntity();
        job.setId(Ids.uuid());
        job.setProjectId(projectId);
        job.setUserId(userId);
        job.setKind("generate_from_prompt");
        job.setStatus("running");
        job.setClientRequestId(clientRequestId == null || clientRequestId.isBlank() ? null : clientRequestId);
        ObjectNode input = JsonUtil.mapper().createObjectNode();
        input.put("prompt", prompt);
        job.setInputPayload(input);
        job.setStartedAt(LocalDateTime.now(ZoneOffset.UTC));
        aiMapper.insertJob(job);

        JsonNode document;
        try {
            JsonNode reply = chat(prompt, null, PLAN_SYSTEM_EXTRA);
            String text = reply.path("reply").asText("");
            document = extractJson(text);
            if (document == null) {
                markFailed(job.getId(), "FORMAT", "模型没有返回可解析的 JSON");
                throw new com.campus.server.common.BizException(
                        com.campus.server.common.ErrorCode.AGENT_UNAVAILABLE,
                        "智能体这次没给出可用的结构，请重试或改用手动搭建");
            }
        } catch (com.campus.server.common.BizException ex) {
            // chat() 抛的 503 需要在 job 上留痕；格式错误上面已经记过了
            if (ex.getCode() == com.campus.server.common.ErrorCode.AGENT_UNAVAILABLE
                    && !"FORMAT".equals(lastErrorCode)) {
                markFailed(job.getId(), com.campus.server.common.ErrorCode.AGENT_UNAVAILABLE.name(),
                        ex.getMessage());
            }
            throw ex;
        }

        aiMapper.updateJobResult(job.getId(), "succeeded", JsonUtil.toJson(document),
                null, null, LocalDateTime.now(ZoneOffset.UTC), LocalDateTime.now(ZoneOffset.UTC));

        ObjectNode target = JsonUtil.mapper().createObjectNode();
        target.put("kind", "document");

        AiProposalEntity proposal = new AiProposalEntity();
        proposal.setId(Ids.uuid());
        proposal.setJobId(job.getId());
        proposal.setProjectId(projectId);
        proposal.setBaseRevision(baseRevision);
        proposal.setTarget(target);
        proposal.setSummary("AI 生成的页面候选稿");
        proposal.setCandidateDocument(document);
        proposal.setRisk("medium");
        proposal.setStatus("proposed");
        aiMapper.insertProposal(proposal);

        return toProposalDto(aiMapper.findProposal(job.getId()));
    }

    public Dtos.AiProposalDto getProposal(String proposalId) {
        AiProposalEntity proposal = aiMapper.findProposal(proposalId);
        if (proposal == null) {
            throw BizException.notFound("提案不存在");
        }
        projectService.loadOwned(proposal.getProjectId());
        return toProposalDto(proposal);
    }

    /**
     * 采用提案：把 candidateDocument 写进项目草稿。
     *
     * <p>两个防呆：
     * <ol>
     *   <li>baseRevision 与服务端当前 draft_revision 不一致 → 409（提案已过期，status 改成 stale）
     *   <li>候选人文档先过 JSON Schema 校验，不过就 422
     * </ol>
     */
    @Transactional
    public Dtos.DraftDto applyProposal(String proposalId, long baseRevision) {
        AiProposalEntity proposal = aiMapper.findProposal(proposalId);
        if (proposal == null) {
            throw BizException.notFound("提案不存在");
        }
        if (!"proposed".equals(proposal.getStatus())) {
            throw new com.campus.server.common.BizException(
                    com.campus.server.common.ErrorCode.REVISION_CONFLICT,
                    "这条提案已经" + ("applied".equals(proposal.getStatus()) ? "被采用过" : "失效") + "了");
        }

        ProjectEntity project = projectService.loadOwned(proposal.getProjectId());
        if (project.getDraftRevision() != baseRevision) {
            aiMapper.markStale(proposalId);
            throw new com.campus.server.common.BizException(
                    com.campus.server.common.ErrorCode.REVISION_CONFLICT,
                    "文档已被修改，当前服务端版本是 " + project.getDraftRevision() + "，请刷新后再采用");
        }

        JsonNode candidate = proposal.getCandidateDocument();
        if (candidate == null || !candidate.isObject()) {
            throw BizException.invalid("提案内容为空");
        }

        Dtos.SaveDraftRequest save = new Dtos.SaveDraftRequest(project.getDraftRevision(), candidate);
        projectService.saveDraft(project.getId(), save);

        long newRevision = project.getDraftRevision() + 1;
        aiMapper.markApplied(proposalId, newRevision, CurrentUser.require().userId());

        return new Dtos.DraftDto(newRevision, candidate, Ids.nowIso());
    }

    public Dtos.AiProposalDto toProposalDto(AiProposalEntity proposal) {
        return new Dtos.AiProposalDto(proposal.getId(), proposal.getJobId(), proposal.getProjectId(),
                proposal.getBaseRevision(), proposal.getTarget(), proposal.getSummary(),
                proposal.getCandidateDocument(), proposal.getOperations(), proposal.getRationale(),
                proposal.getRisk(), proposal.getStatus());
    }

    /** 给 /health 用。 */
    public Map<String, Object> status() {
        return Map.of("agentAlive", agentAlive());
    }

    // ================================================================ 内部工具

    private volatile String lastErrorCode;

    private void markFailed(String jobId, String errorCode, String message) {
        this.lastErrorCode = errorCode;
        aiMapper.updateJobResult(jobId, "failed", null, errorCode, message,
                LocalDateTime.now(ZoneOffset.UTC), LocalDateTime.now(ZoneOffset.UTC));
    }

    /** 规划器提示词：与前端 {@code planner.ts} 的 DocPlan 结构保持一致。 */
    static final String PLAN_SYSTEM_EXTRA =
            "你是校园活动页面规划器。只输出一个 JSON 对象，不要输出解释、不要在 JSON 外写文字、不要用代码块包裹。"
            + "结构：{\"intent\":\"\",\"reason\":\"\",\"title\":\"\","
            + "\"theme\":{\"primary\":\"#rrggbb\",\"accent\":\"#rrggbb\",\"bg\":\"#rrggbb\","
            + "\"text\":\"#rrggbb\",\"radius\":12,\"fontScale\":1,\"spacing\":12},"
            + "\"pages\":[{\"name\":\"首页\",\"role\":\"home\",\"blocks\":[{\"type\":\"banner\",\"props\":{}}]}]}。"
            + "pages 里至少有一页 role=home。block.type 只能是："
            + "nav, banner, heading, text, image, infoCard, button, form, radio, checkbox, qrcode, divider, countdown。";

    /**
     * 从模型回复里抠出第一个完整 JSON 对象（允许前后有解释文字或 ``` 包裹）。
     * 与前端 {@code extractJson} 逻辑一致，保证两端对同一段回复的解析结果相同。
     */
    static JsonNode extractJson(String text) {
        if (text == null || text.isEmpty()) {
            return null;
        }
        String cleaned = text.replaceAll("(?i)```json", "```").replace("```", "");
        int start = cleaned.indexOf('{');
        if (start < 0) {
            return null;
        }
        int depth = 0;
        boolean inString = false;
        boolean escaped = false;
        for (int i = start; i < cleaned.length(); i++) {
            char c = cleaned.charAt(i);
            if (inString) {
                if (escaped) {
                    escaped = false;
                } else if (c == '\\') {
                    escaped = true;
                } else if (c == '"') {
                    inString = false;
                }
                continue;
            }
            if (c == '"') {
                inString = true;
            } else if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    try {
                        return JsonUtil.mapper().readTree(cleaned.substring(start, i + 1));
                    } catch (Exception ex) {
                        return null;
                    }
                }
            }
        }
        return null;
    }
}
