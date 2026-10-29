package com.campus.server.entity;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 auth_sessions。refresh_token 只存 sha256，明文只出现在接口响应里。
 */
@Data
public class AuthSessionEntity {
    private String id;
    private String userId;
    private String tokenHash;
    private String userAgent;
    private LocalDateTime expiresAt;
    private LocalDateTime revokedAt;
    private LocalDateTime createdAt;
}
