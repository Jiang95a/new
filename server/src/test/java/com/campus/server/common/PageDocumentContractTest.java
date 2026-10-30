package com.campus.server.common;

import com.campus.server.service.DocumentNormalizer;
import com.campus.server.support.JsonUtil;
import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.Test;
import org.yaml.snakeyaml.Yaml;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PageDocumentContractTest {

    private final PageDocumentValidator validator = new PageDocumentValidator();
    private final DocumentNormalizer normalizer = new DocumentNormalizer();

    @Test
    void acceptsControlledPageDocument() throws Exception {
        JsonNode document = JsonUtil.mapper().readTree("""
                {
                  "title": "社团招新",
                  "theme": {
                    "primary": "#2563eb",
                    "accent": "#7c3aed",
                    "bg": "#ffffff",
                    "text": "#111827"
                  },
                  "pages": [{
                    "id": "page-home",
                    "name": "首页",
                    "role": "home",
                    "blocks": [{
                      "id": "block-banner",
                      "type": "banner",
                      "props": {"title": "欢迎报名"},
                      "hidden": false
                    }]
                  }]
                }
                """);

        assertDoesNotThrow(() -> validator.validateOrThrow(document));
        assertDoesNotThrow(() -> normalizer.assertPublishable(document));
    }

    @Test
    void rejectsLegacyComponentsShape() throws Exception {
        JsonNode document = JsonUtil.mapper().readTree("""
                {
                  "title": "旧结构",
                  "pages": [{
                    "id": "page-home",
                    "components": []
                  }]
                }
                """);

        BizException error = assertThrows(BizException.class, () -> validator.validateOrThrow(document));
        assertEquals(ErrorCode.PAGE_DOCUMENT_INVALID, error.getCode());
    }

    @Test
    void removesHiddenBlocksFromPublishedSnapshot() throws Exception {
        JsonNode document = JsonUtil.mapper().readTree("""
                {
                  "title": "发布测试",
                  "pages": [{
                    "id": "page-home",
                    "role": "home",
                    "blocks": [
                      {"id": "visible", "type": "text", "props": {"text": "保留"}, "hidden": false},
                      {"id": "hidden", "type": "text", "props": {"text": "删除"}, "hidden": true}
                    ]
                  }]
                }
                """);

        JsonNode published = normalizer.normalizeForPublish(document, "demo", "http://localhost/p/demo");
        JsonNode blocks = published.path("pages").get(0).path("blocks");
        assertEquals(1, blocks.size());
        assertEquals("visible", blocks.get(0).path("id").asText());
        assertEquals("demo", published.path("slug").asText());
        assertTrue(published.path("published").path("url").asText().endsWith("/p/demo"));
    }

    @Test
    void openApiContractIsValidYaml() throws Exception {
        String source = Files.readString(Path.of("../docs/api/openapi.yaml"));
        Object parsed = new Yaml().load(source);
        assertTrue(parsed instanceof java.util.Map<?, ?>);
    }
}
