package com.campus.server.entity;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 users。
 */
@Data
public class UserEntity {
    private String id;
    private String email;
    private String passwordHash;
    private String displayName;
    /** active | disabled */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
