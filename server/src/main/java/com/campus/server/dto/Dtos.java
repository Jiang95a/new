package com.campus.server.dto;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * 请求体 / 响应体。字段名严格按 docs/api/openapi.yaml，
 * 个别地方补了前端实际用到的字段（已在注释里标出）。
 */
public final class Dtos {

    private Dtos() {
    }

    // ================================================================ Auth

    public record RegisterRequest(
            @jakarta.validation.constraints.NotBlank(message = "邮箱不能为空")
            @jakarta.validation.constraints.Email(message = "邮箱格式不正确")
            @jakarta.validation.constraints.Size(max = 190, message = "邮箱过长")
            String email,

            @jakarta.validation.constraints.NotBlank(message = "密码不能为空")
            @jakarta.validation.constraints.Size(min = 8, max = 128, message = "密码长度需在 8-128 之间")
            String password,

            @jakarta.validation.constraints.NotBlank(message = "昵称不能为空")
            @jakarta.validation.constraints.Size(min = 1, max = 80, message = "昵称长度需在 1-80 之间")
            String displayName
    ) {
    }

    public record LoginRequest(String email, String password) {
    }

    public record RefreshRequest(String refreshToken) {
    }

    public record UserDto(String id, String email, String displayName, String status) {
    }

    public record AuthResponse(String accessToken, String refreshToken, UserDto user) {
    }

    // ================================================================ Templates

    public record TemplateDto(String id, String code, String name, String category,
                              String description, String coverUrl, JsonNode document) {
    }

    // ================================================================ Projects

    public record CreateProjectRequest(
            @jakarta.validation.constraints.NotBlank(message = "标题不能为空")
            @jakarta.validation.constraints.Size(max = 160, message = "标题最多 160 字")
            String title,
            String description,
            String templateId,
            JsonNode initialDocument
    ) {
    }

    public record UpdateProjectRequest(String title, String description) {
    }

    public record DuplicateProjectRequest(
            @jakarta.validation.constraints.NotBlank(message = "标题不能为空")
            @jakarta.validation.constraints.Size(max = 160, message = "标题最多 160 字")
            String title
    ) {
    }

    public record ProjectDto(String id,
                             String title,
                             String description,
                             String status,
                             long draftRevision,
                             String publicSlug,
                             String publicUrl,
                             String publishedVersionId,
                             long submissionCount,
                             String createdAt,
                             String updatedAt,
                             JsonNode draftDocument) {
    }

    // ================================================================ Draft

    public record DraftDto(long revision, JsonNode document, String updatedAt) {
    }

    /**
     * 刻意不在字段上加 @NotNull：文档缺失属于「页面文档不合法」（422），
     * 而不是「参数格式错误」（400）。缺字段的判断放在 ProjectService.saveDraft 里。
     */
    public record SaveDraftRequest(Long baseRevision, JsonNode document) {
    }

    public record SaveDraftResult(long revision, String savedAt) {
    }

    // ================================================================ Versions

    public record VersionDto(String id, int versionNo, String source, JsonNode document, String createdAt) {
    }

    public record CreateVersionRequest(
            @jakarta.validation.constraints.NotNull(message = "baseRevision 不能为空")
            Long baseRevision,
            String source
    ) {
    }

    // ================================================================ Publish

    public record PublishRequest(String versionId, String slug,
                                 JsonNode publishSettings) {
    }

    public record PublishResult(String publicSlug, String publicUrl, String publishedVersionId, String publishedAt) {
    }

    // ================================================================ Public

    public record PublicActivityDto(String slug, String title, String status, JsonNode document,
                                    JsonNode publishSettings) {
    }

    public record SubmissionRequest(
            String pageId,
            String formComponentId,
            JsonNode answers,
            String idempotencyKey
    ) {
    }

    public record SubmissionResult(String submissionId, String status, String submittedAt) {
    }

    public record SubmissionDto(String id, String pageId, String formComponentId,
                                JsonNode answers, String status, String submittedAt) {
    }

    // ================================================================ Assets

    public record AssetUploadResult(String assetId, String objectKey, String url, String mimeType,
                                    long sizeBytes, Integer width, Integer height) {
    }

    // ================================================================ AI

    public record AiJobDto(String id, String projectId, String kind, String status,
                           JsonNode result, String errorCode, String errorMessage, String createdAt) {
    }

    public record AiProposalDto(String id, String jobId, String projectId, long baseRevision,
                                JsonNode target, String summary, JsonNode candidateDocument,
                                JsonNode operations, JsonNode rationale, String risk, String status) {
    }

    public record AiProposalApplyRequest(
            @jakarta.validation.constraints.NotNull(message = "baseRevision 不能为空")
            Long baseRevision
    ) {
    }

    // ================================================================ Exports

    public record ExportJobDto(String id, String projectId, String status, String objectKey,
                               String errorMessage, String createdAt, String finishedAt) {
    }

    // ================================================================ Health & Analytics

    /** 分页元信息，序列化进 ApiResponse 的 pagination 字段。 */
    public record PageMeta(int page, int pageSize, long total) {
    }

    /** 服务层往控制器传「列表 + 分页」的载体。 */
    public record PagedResultHolder<T>(java.util.List<T> data, PageMeta meta) {
    }

    public record HealthDto(String status, String app, Map<String, Object> database,
                            Map<String, Object> agent, String time) {
    }

    public record AnalyticsSummaryDto(long submissions,
                                      long validSubmissions,
                                      long pageViews,
                                      long publishedPages,
                                      List<Map<String, Object>> byDay) {
    }

    /** 供前端 select 使用的键值对。 */
    @Data
    public static class Option {
        private String value;
        private String label;
    }
}
