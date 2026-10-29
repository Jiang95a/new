package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 templates。document 存的是前端 DocPlan/Doc 结构（见 web/src/data/templates.ts）。
 */
@Data
public class TemplateEntity {
    private String id;
    private String code;
    private String name;
    /** recruitment | registration | vote | checkin */
    private String category;
    private String description;
    private String coverUrl;
    private JsonNode document;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
