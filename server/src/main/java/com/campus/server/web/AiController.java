package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.dto.Dtos;
import com.campus.server.service.AiService;
import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * AI 相关接口。
 *
 * <p>agent（FastAPI，8000）不通时这里统一返回 503 AGENT_UNAVAILABLE，
 * 前端必须按「降级到手动搭建」处理，不能让编辑器卡住。
 */
@RestController
@RequestMapping("/ai")
public class AiController {

    private final AiService aiService;

    public AiController(AiService aiService) {
        this.aiService = aiService;
    }

    /** 透传 /chat，给编辑器 AiPanel 用。 */
    @PostMapping("/chat")
    public ApiResponse.Envelope<JsonNode> chat(@RequestBody Map<String, Object> body) {
        String message = body.get("message") == null ? null : String.valueOf(body.get("message"));
        String threadId = body.get("thread_id") == null ? null : String.valueOf(body.get("thread_id"));
        String systemExtra = body.get("system_extra") == null ? null : String.valueOf(body.get("system_extra"));
        return ApiResponse.ok(aiService.chat(message, threadId, systemExtra));
    }

    @GetMapping("/agent/health")
    public ApiResponse.Envelope<Map<String, Object>> agentHealth() {
        return ApiResponse.ok(Map.of("ok", aiService.agentAlive()));
    }

    @PostMapping("/poster/extract")
    public ApiResponse.Envelope<JsonNode> extractPoster(
            @RequestParam(required = false) String url,
            @RequestBody(required = false) Map<String, Object> body) {
        String dataUrl = body == null || body.get("dataUrl") == null
                ? null : String.valueOf(body.get("dataUrl"));
        return ApiResponse.ok(aiService.extractPoster(dataUrl, url));
    }

    /** 按一句话需求生成候选页面，返回 ai_proposals 记录（不直接改草稿）。 */
    @PostMapping("/projects/{projectId}/generate")
    public ApiResponse.Envelope<Dtos.AiProposalDto> generate(@PathVariable String projectId,
                                                             @RequestBody Map<String, Object> body) {
        String prompt = body.get("prompt") == null ? null : String.valueOf(body.get("prompt"));
        long baseRevision = body.get("baseRevision") == null ? 0L
                : Long.parseLong(String.valueOf(body.get("baseRevision")));
        String clientRequestId = body.get("clientRequestId") == null ? null
                : String.valueOf(body.get("clientRequestId"));
        return ApiResponse.ok(aiService.generateFromPrompt(projectId, prompt, baseRevision, clientRequestId));
    }

    @GetMapping("/proposals/{proposalId}")
    public ApiResponse.Envelope<Dtos.AiProposalDto> getProposal(@PathVariable String proposalId) {
        return ApiResponse.ok(aiService.getProposal(proposalId));
    }

    /** 采用提案：把候选稿写进草稿（带 baseRevision 乐观锁）。 */
    @PostMapping("/proposals/{proposalId}/apply")
    public ApiResponse.Envelope<Dtos.DraftDto> apply(@PathVariable String proposalId,
                                                     @Valid @RequestBody Dtos.AiProposalApplyRequest request) {
        return ApiResponse.ok(aiService.applyProposal(proposalId, request.baseRevision()));
    }
}
