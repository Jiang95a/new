package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.dto.Dtos;
import com.campus.server.entity.TemplateEntity;
import com.campus.server.mapper.TemplateMapper;
import com.campus.server.support.JsonUtil;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 模板列表。数据来自 templates 表（002_seed.sql 已经塞了 recruitment-club 等几条）。
 */
@Service
public class TemplateService {

    private final TemplateMapper templateMapper;

    public TemplateService(TemplateMapper templateMapper) {
        this.templateMapper = templateMapper;
    }

    public List<Dtos.TemplateDto> list(String category) {
        List<TemplateEntity> rows = templateMapper.listActive(
                (category == null || category.isBlank()) ? null : category);
        return rows.stream().map(this::toDto).toList();
    }

    public Dtos.TemplateDto get(String id) {
        TemplateEntity entity = templateMapper.findById(id);
        if (entity == null) {
            throw BizException.notFound("模板不存在");
        }
        return toDto(entity);
    }

    private Dtos.TemplateDto toDto(TemplateEntity entity) {
        JsonNode document = entity.getDocument();
        return new Dtos.TemplateDto(entity.getId(), entity.getCode(), entity.getName(),
                entity.getCategory(), entity.getDescription(), entity.getCoverUrl(), document);
    }

    /** 供 ProjectService 取模板文档。 */
    public JsonNode documentOf(String templateId) {
        TemplateEntity entity = templateMapper.findById(templateId);
        return entity == null ? null : entity.getDocument();
    }
}
