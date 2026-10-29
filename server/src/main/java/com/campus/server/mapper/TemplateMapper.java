package com.campus.server.mapper;

import com.campus.server.entity.TemplateEntity;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface TemplateMapper {

    String COLUMNS = 
            "id, code, name, category, description, cover_url, document, "
          + "is_active, created_at, updated_at ";

    @Select("<script>SELECT " + COLUMNS + " FROM templates WHERE is_active = 1 "
            + "<if test='category != null and category != \"\"'> AND category = #{category} </if>"
            + " ORDER BY category, name</script>")
    List<TemplateEntity> listActive(@Param("category") String category);

    @Select("SELECT " + COLUMNS + " FROM templates WHERE id = #{id} LIMIT 1")
    TemplateEntity findById(@Param("id") String id);

    @Select("SELECT " + COLUMNS + " FROM templates WHERE code = #{code} LIMIT 1")
    TemplateEntity findByCode(@Param("code") String code);
}
