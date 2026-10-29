package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 activity_events / export_jobs。
 */
public final class MiscEntities {
    private MiscEntities() {
    }

    /** 表 activity_events：公开页访问、表单提交等埋点。 */
    @Data
    public static class ActivityEventEntity {
        private Long id;
        private String projectId;
        /** public_page_view | form_started | form_submitted | submission_succeeded | submission_rejected */
        private String eventType;
        private String pageId;
        private JsonNode metadata;
        private LocalDateTime occurredAt;
    }

    /** 表 export_jobs：报名数据导出。 */
    @Data
    public static class ExportJobEntity {
        private String id;
        private String projectId;
        private String requestedBy;
        /** queued | running | succeeded | failed | expired */
        private String status;
        private JsonNode filters;
        private String objectKey;
        private String errorMessage;
        private LocalDateTime expiresAt;
        private LocalDateTime createdAt;
        private LocalDateTime finishedAt;
    }
}
