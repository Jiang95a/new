package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 form_submissions。(project_id, idempotency_key) 唯一，重复提交不会产生第二条记录。
 */
@Data
public class FormSubmissionEntity {
    private String id;
    private String projectId;
    private String versionId;
    private String pageId;
    private String formComponentId;
    private JsonNode answers;
    private String idempotencyKey;
    private String submitterHash;
    /** valid | invalid */
    private String status;
    private LocalDateTime submittedAt;
}
