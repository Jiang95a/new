package com.campus.server.support;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.NullNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Jackson 的统一入口。Spring Boot 的 ObjectMapper 已经配好 UTC / 毫秒精度，直接复用。
 */
@Component
public final class JsonUtil {

    private static ObjectMapper mapper = new ObjectMapper();

    private JsonUtil() {
    }

    @Autowired
    void setMapper(ObjectMapper objectMapper) {
        mapper = objectMapper;
    }

    public static ObjectMapper mapper() {
        return mapper;
    }

    public static JsonNode toJsonNode(Object value) {
        if (value == null) {
            return NullNode.getInstance();
        }
        if (value instanceof JsonNode node) {
            return node;
        }
        return mapper.valueToTree(value);
    }

    public static <T> T fromJson(String json, Class<T> type) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return mapper.readValue(json, type);
        } catch (Exception ex) {
            throw new IllegalStateException("JSON 解析失败: " + ex.getMessage(), ex);
        }
    }

    public static <T> T fromJson(String json, TypeReference<T> type) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return mapper.readValue(json, type);
        } catch (Exception ex) {
            throw new IllegalStateException("JSON 解析失败: " + ex.getMessage(), ex);
        }
    }

    public static String toJson(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return mapper.writeValueAsString(value);
        } catch (Exception ex) {
            throw new IllegalStateException("JSON 序列化失败: " + ex.getMessage(), ex);
        }
    }
}
