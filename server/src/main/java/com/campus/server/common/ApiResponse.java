package com.campus.server.common;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 统一响应外壳。
 *
 * <pre>
 * 成功：{ "data": ..., "requestId": "..." }
 * 分页：{ "data": [...], "pagination": {page,pageSize,total}, "requestId": "..." }
 * 失败：{ "error": {"code","message","details"}, "requestId": "..." }
 * </pre>
 *
 * 注意：Pagination 必须在 data 之后序列化，这里用 JsonInclude 保证空字段不出现。
 */
public final class ApiResponse {

    private ApiResponse() {
    }

    public static <T> Envelope<T> ok(T data) {
        return new Envelope<>(data, null, RequestIdHolder.get());
    }

    public static <T> PagedEnvelope<List<T>> page(List<T> data, long total, int page, int pageSize) {
        return new PagedEnvelope<>(data, new Pagination(page, pageSize, total), RequestIdHolder.get());
    }

    public static <T> PagedEnvelope<List<T>> page(List<T> data, Pagination pagination) {
        return new PagedEnvelope<>(data, pagination, RequestIdHolder.get());
    }

    public static ErrorEnvelope error(ErrorCode code, String message, Object details) {
        return new ErrorEnvelope(new ErrorBody(code.name(), message, details), RequestIdHolder.get());
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Envelope<T>(T data, Pagination pagination, String requestId) {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record PagedEnvelope<T>(T data, Pagination pagination, String requestId) {
    }

    public record Pagination(int page, int pageSize, long total) {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ErrorEnvelope(ErrorBody error, String requestId) {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ErrorBody(String code, String message, Object details) {
    }

    /**
     * 请求级 requestId：由过滤器写入 MDC / ThreadLocal，异常兜底路径也能取到。
     */
    public static final class RequestIdHolder {
        private static final ThreadLocal<String> HOLDER = new ThreadLocal<>();

        private RequestIdHolder() {
        }

        public static void set(String value) {
            HOLDER.set(value);
        }

        public static String get() {
            String value = HOLDER.get();
            return value != null ? value : UUID.randomUUID().toString();
        }

        public static void clear() {
            HOLDER.remove();
        }
    }

    /** ISO-8601 毫秒精度的工具，供 DTO 使用。 */
    public static Instant now() {
        return Instant.now();
    }
}
