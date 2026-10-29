package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 ai_jobs。后端只负责记账与转发，真正的推理在 agent/（FastAPI）。
 */
@Data
public class AiJobEntity {
    private String id;
    private String projectId;
    private String userId;
    /** generate_from_prompt | generate_from_poster | component_suggestions | quality_check */
    private String kind;
    /** queued | running | succeeded | failed | cancelled */
    private String status;
    private String clientRequestId;
    private JsonNode inputPayload;
    private JsonNode resultPayload;
    private String modelProvider;
    private String modelName;
    private String errorCode;
    private String errorMessage;
    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
    private LocalDateTime createdAt;
}
