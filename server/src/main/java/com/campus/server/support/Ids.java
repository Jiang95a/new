package com.campus.server.support;

import com.campus.server.common.BizException;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;

/**
 * 小工具集合：UUID、slug、时间格式、哈希、幂等键。
 */
@Component
public final class Ids {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final DateTimeFormatter ISO_MILLIS =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(ZoneOffset.UTC);

    private Ids() {
    }

    public static String uuid() {
        return UUID.randomUUID().toString();
    }

    /** 数据库 DATETIME（UTC 存储）→ 契约里的 ISO-8601 字符串。 */
    public static String iso(LocalDateTime time) {
        if (time == null) {
            return null;
        }
        return ISO_MILLIS.format(time.toInstant(ZoneOffset.UTC));
    }

    public static String nowIso() {
        return ISO_MILLIS.format(Instant.now());
    }

    public static LocalDateTime nowUtc() {
        return LocalDateTime.now(ZoneOffset.UTC);
    }

    /**
     * 标题 → 访问路径。中文标题做不出有意义的 slug，回退到 activity-<随机>。
     */
    public static String slugify(String title) {
        if (title == null) {
            return null;
        }
        String normalized = java.text.Normalizer.normalize(title, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        String candidate = normalized.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        if (candidate.length() > 48) {
            candidate = candidate.substring(0, 48).replaceAll("-+$", "");
        }
        if (candidate.isBlank()) {
            return "activity-" + randomToken(6);
        }
        // 纯数字或过短的 slug 既没有辨识度也不好念，统一加前缀补足
        if (candidate.matches("^[0-9]+$")) {
            candidate = "activity-" + candidate;
        }
        if (candidate.length() < 3) {
            candidate = candidate + "-" + randomToken(4);
        }
        return candidate;
    }

    public static String randomToken(int length) {
        String alphabet = "abcdefghijkmnpqrstuvwxyz23456789";
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(alphabet.charAt(RANDOM.nextInt(alphabet.length())));
        }
        return sb.toString();
    }

    public static String sha256(String raw) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(raw.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception ex) {
            throw new IllegalStateException("SHA-256 不可用", ex);
        }
    }

    /** 幂等键：前端没传就由后端补一个 UUID；非法格式直接 400。 */
    public static String idempotencyKey(String provided) {
        if (provided == null || provided.isBlank()) {
            return uuid();
        }
        String trimmed = provided.trim();
        if (trimmed.length() > 100) {
            throw BizException.invalid("idempotencyKey 过长");
        }
        return trimmed;
    }

    /**
     * 用「项目 + 幂等键」拼出稳定的去重坐标，避免跨项目串号。
     *
     * <p>form_submissions.idempotency_key 是 char(36)，所以取 sha256 的前 36 位十六进制。
     * 36 位十六进制 ≈ 144 bit，撞键概率可以忽略；返回值保持定长，也不会再被 MySQL 截断。
     */
    public static String scopedIdempotencyKey(String projectId, String key) {
        String digest = sha256(projectId + ":" + key);
        return digest.length() > 36 ? digest.substring(0, 36) : digest;
    }
}
