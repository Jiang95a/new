package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 page_versions。每次发布都会固化成一条版本，公开页读的是版本而不是草稿。
 */
@Data
public class PageVersionEntity {
    private String id;
    private String projectId;
    private Integer versionNo;
    private JsonNode document;
    /** manual | ai | template */
    private String source;
    private String createdBy;
    private LocalDateTime createdAt;
}
