package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 ai_proposals。AI 给的是「建议」，必须用户点应用才改草稿 —— 这是 PRD 的硬要求。
 */
@Data
public class AiProposalEntity {
    private String id;
    private String jobId;
    private String projectId;
    private String baseVersionId;
    private Long baseRevision;
    private JsonNode target;
    private String summary;
    private JsonNode candidateDocument;
    private JsonNode operations;
    private JsonNode rationale;
    /** low | medium | high */
    private String risk;
    /** proposed | applied | rejected | stale */
    private String status;
    private Long appliedRevision;
    private String appliedBy;
    private LocalDateTime appliedAt;
    private LocalDateTime createdAt;
}
