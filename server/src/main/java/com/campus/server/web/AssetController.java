package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.common.BizException;
import com.campus.server.security.CurrentUser;
import com.campus.server.service.FileStorage;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

/**
 * 图片上传 + 文件读取。
 *
 * <p>V1 落本地磁盘，接口形状按对象存储设计，将来换 OSS 只改 {@link FileStorage}。
 * 只允许 JPG / PNG / WebP（与契约一致），大小上限见 {@code app.upload.max-mb}。
 */
@RestController
public class AssetController {

    private static final Set<String> ALLOWED = Set.of("image/jpeg", "image/png", "image/webp");

    private final FileStorage storage;
    private final com.campus.server.mapper.MiscMapper miscMapper;

    public AssetController(FileStorage storage, com.campus.server.mapper.MiscMapper miscMapper) {
        this.storage = storage;
        this.miscMapper = miscMapper;
    }

    /** 上传图片，返回可直接塞进 image 组件 props 的 url。 */
    @PostMapping("/assets")
    public ApiResponse.Envelope<Map<String, Object>> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) String projectId) throws IOException {
        try {
            return ApiResponse.ok(doUpload(file, projectId));
        } catch (java.security.NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 不可用", ex);
        }
    }

    private Map<String, Object> doUpload(MultipartFile file, String projectId)
            throws IOException, java.security.NoSuchAlgorithmException {
        String userId = CurrentUser.require().userId();
        if (file == null || file.isEmpty()) {
            throw BizException.invalid("文件为空");
        }
        String mime = file.getContentType();
        if (mime == null || !ALLOWED.contains(mime)) {
            throw BizException.invalid("只支持 JPG / PNG / WebP");
        }

        String ext = switch (mime) {
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            default -> ".jpg";
        };
        String assetId = com.campus.server.support.Ids.uuid();
        String objectKey = "assets/" + userId + "/" + assetId + ext;
        byte[] bytes = file.getBytes();
        storage.write(objectKey, bytes);

        com.campus.server.entity.ProjectAssetEntity asset =
                new com.campus.server.entity.ProjectAssetEntity();
        asset.setId(assetId);
        asset.setOwnerId(userId);
        asset.setProjectId(projectId);
        asset.setObjectKey(objectKey);
        asset.setMimeType(mime);
        asset.setSizeBytes((long) bytes.length);
        asset.setSha256(com.campus.server.support.Ids.sha256(
                java.util.HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256")
                        .digest(bytes)) + ":" + objectKey));
        asset.setStatus("ready");
        miscMapper.insertAsset(asset);

        return Map.of(
                "assetId", assetId,
                "objectKey", objectKey,
                "url", storage.publicUrl(objectKey),
                "mimeType", mime,
                "sizeBytes", bytes.length);
    }

    /**
     * 文件读取：发布页和编辑器都可能直接 {@code <img src>}，所以放行。
     *
     * <p>{@code **} 而不是 {@code .+}：objectKey 是 {@code assets/<uid>/<file>.png} 这种多段路径，
     * Spring 6 起 {@code {var:.+}} 只匹配单段，会把带斜杠的 key 判成 404。
     */
    @GetMapping("/files/**")
    public ResponseEntity<byte[]> read(jakarta.servlet.http.HttpServletRequest request) {
        String path = request.getRequestURI();
        int at = path.indexOf("/files/");
        String key = at >= 0 ? path.substring(at + "/files/".length()) : "";
        if (key.startsWith("/")) {
            key = key.substring(1);
        }
        if (key.isBlank() || !storage.exists(key)) {
            throw BizException.notFound("文件不存在");
        }
        byte[] bytes = storage.read(key);
        var asset = miscMapper.findAssetByKey(key);
        MediaType type = asset != null && asset.getMimeType() != null
                ? MediaType.parseMediaType(asset.getMimeType())
                : MediaType.APPLICATION_OCTET_STREAM;
        return ResponseEntity.ok()
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                .contentType(type)
                .body(bytes);
    }
}
