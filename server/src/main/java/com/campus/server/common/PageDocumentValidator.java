package com.campus.server.common;

import com.campus.server.support.JsonUtil;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion;
import com.networknt.schema.ValidationMessage;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Comparator;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * PageDocument 契约校验。
 *
 * <p>校验的是 <b>前端真正在用的那一版结构</b>（web/src/types/editor.ts 的 Doc），
 * 不是 openapi.yaml 里那份早期草稿 —— 契约冲突已在 docs 记录，等三端对齐后换 schema 即可。
 *
 * <p>注意：openapi.yaml 写的是 snake_case 组件名（info_card），前端写的是 camelCase（infoCard）。
 * 这里以<b>前端</b>为准，因为后端要落库的就是前端提交的 JSON。
 */
@Component
public class PageDocumentValidator {

    private final JsonSchema schema;

    public PageDocumentValidator() {
        try (var in = new ClassPathResource("schema/page-document.schema.json").getInputStream()) {
            JsonSchemaFactory factory = JsonSchemaFactory.getInstance(SpecVersion.VersionFlag.V202012);
            this.schema = factory.getSchema(in);
        } catch (Exception ex) {
            throw new IllegalStateException("加载 page-document.schema.json 失败", ex);
        }
    }

    /** 校验失败直接抛 422 PAGE_DOCUMENT_INVALID，details 里带具体哪几个字段不对。 */
    public void validateOrThrow(Object document) {
        if (document == null) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "页面文档不能为空");
        }
        try {
            var node = JsonUtil.toJsonNode(document);
            Set<ValidationMessage> messages = schema.validate(node);
            if (!messages.isEmpty()) {
                var details = messages.stream()
                        .sorted(Comparator.comparing(ValidationMessage::getMessage))
                        .limit(20)
                        .map(m -> m.getInstanceLocation() + " " + m.getMessage())
                        .collect(Collectors.toList());
                throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID,
                        "页面文档结构不合法", details);
            }
        } catch (BizException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new BizException(ErrorCode.PAGE_DOCUMENT_INVALID, "页面文档无法解析: " + ex.getMessage());
        }
    }
}
