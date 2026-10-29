package com.campus.server.entity;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表 project_assets。object_key 是唯一对外的图片标识（防 SSRF，不接受任意 URL）。
 */
@Data
public class ProjectAssetEntity {
    private String id;
    private String ownerId;
    private String projectId;
    private String objectKey;
    private String mimeType;
    private Long sizeBytes;
    private String sha256;
    private Integer width;
    private Integer height;
    /** pending | ready | rejected */
    private String status;
    private LocalDateTime createdAt;
}
