package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 projects。draft_revision 是前端乐观锁的核心：
 * PUT /draft 时带 baseRevision，和这里的值不相等就返回 409。
 */
@Data
public class ProjectEntity {
    private String id;
    private String ownerId;
    private String templateId;
    private String title;
    private String description;
    /** draft | published | unpublished | archived */
    private String status;
    private JsonNode draftDocument;
    private Long draftRevision;
    private String publicSlug;
    private String publishedVersionId;
    private JsonNode publishSettings;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime deletedAt;
}
