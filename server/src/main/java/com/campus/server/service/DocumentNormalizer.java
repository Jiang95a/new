package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.common.ErrorCode;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 把「未发布的草稿」变成「公开页能读的文档」，并做发布前的最后一道体检。
 *
 * <p>为什么需要这一步：前端 Doc 结构由三端共用，但公开页只该看到最终形态 ——
 * 隐藏的组件要剔除、slug 要落定、id 要有。这里做一次规范化，避免下游各处重复处理。
 */
@Component
public class DocumentNormalizer {

    public JsonNode normalizeForPublish(JsonNode draft, String slug, String publicUrl) {
        if (draft == null || draft.isNull()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "草稿是空的，先保存一版再发布");
        }
        ObjectNode doc = draft.deepCopy();

        doc.put("slug", slug);
        ObjectNode published = doc.putObject("published");
        published.put("slug", slug);
        published.put("url", publicUrl);
        published.put("at", System.currentTimeMillis());

        // 隐藏的组件不进公开页，直接剔掉（前端 BlockView 也会过滤，这里双保险）
        JsonNode pages = doc.get("pages");
        if (pages != null && pages.isArray()) {
            for (JsonNode page : pages) {
                if (page instanceof ObjectNode pageNode) {
                    JsonNode blocks = pageNode.get("blocks");
                    if (blocks != null && blocks.isArray()) {
                        List<JsonNode> kept = new ArrayList<>();
                        for (JsonNode block : blocks) {
                            if (block.path("hidden").asBoolean(false)) {
                                continue;
                            }
                            kept.add(block);
                        }
                        var array = pageNode.putArray("blocks");
                        kept.forEach(array::add);
                    }
                }
            }
        }
        return doc;
    }

    /**
     * 发布前体检：至少要有一页 home，且页面 id 不能重复。
     * 前端编辑器已经保证了这些，这里防的是脚本直接打接口。
     */
    public void assertPublishable(JsonNode document) {
        JsonNode pages = document.get("pages");
        if (pages == null || !pages.isArray() || pages.isEmpty()) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "至少需要一页才能发布");
        }
        boolean hasHome = false;
        List<String> ids = new ArrayList<>();
        for (JsonNode page : pages) {
            String role = page.path("role").asText("");
            if ("home".equals(role)) {
                hasHome = true;
            }
            String id = page.path("id").asText("");
            if (id.isBlank()) {
                throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "页面缺少 id");
            }
            if (ids.contains(id)) {
                throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "页面 id 重复: " + id);
            }
            ids.add(id);
        }
        if (!hasHome) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "缺少 home 角色的首页");
        }
    }

    /** 从文档里找出所有表单组件，公开提交时要校验 pageId + formComponentId 真实存在。 */
    public List<String> formComponentIds(JsonNode document) {
        List<String> result = new ArrayList<>();
        JsonNode pages = document.get("pages");
        if (pages == null || !pages.isArray()) {
            return result;
        }
        for (JsonNode page : pages) {
            JsonNode blocks = page.get("blocks");
            if (blocks == null || !blocks.isArray()) {
                continue;
            }
            for (JsonNode block : blocks) {
                if ("form".equals(block.path("type").asText())) {
                    result.add(block.path("id").asText(""));
                }
            }
        }
        return result;
    }

    /** 统计文档里所有必填字段，公开提交时按它校验答案完整性。 */
    public List<Map<String, Object>> requiredFields(JsonNode document, String pageId, String blockId) {
        List<Map<String, Object>> fields = new ArrayList<>();
        JsonNode pages = document.get("pages");
        if (pages == null || !pages.isArray()) {
            return fields;
        }
        for (JsonNode page : pages) {
            if (!pageId.equals(page.path("id").asText())) {
                continue;
            }
            JsonNode blocks = page.get("blocks");
            if (blocks == null || !blocks.isArray()) {
                continue;
            }
            for (JsonNode block : blocks) {
                if (!blockId.equals(block.path("id").asText())) {
                    continue;
                }
                JsonNode list = block.path("props").get("fields");
                if (list == null || !list.isArray()) {
                    continue;
                }
                for (JsonNode field : list) {
                    if (!field.path("required").asBoolean(false)) {
                        continue;
                    }
                    fields.add(Map.of(
                            "id", field.path("id").asText(""),
                            "label", field.path("label").asText(""),
                            "type", field.path("type").asText("text")
                    ));
                }
            }
        }
        return fields;
    }

    /** 便于调试：读取文档顶层的某个标量字段。 */
    public String textField(JsonNode node, String field) {
        if (node == null) {
            return null;
        }
        JsonNode value = node.get(field);
        return value == null || value.isNull() ? null : value.asText();
    }
}
