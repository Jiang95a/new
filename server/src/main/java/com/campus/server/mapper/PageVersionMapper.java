package com.campus.server.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.campus.server.entity.PageVersionEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PageVersionMapper {

    String COLUMNS = "id, project_id, version_no, document, source, created_by, created_at";

    @Select("SELECT " + COLUMNS + " FROM page_versions WHERE project_id = #{projectId} ORDER BY version_no DESC")
    List<PageVersionEntity> listByProject(@Param("projectId") String projectId);

    @Select("SELECT " + COLUMNS + " FROM page_versions WHERE id = #{id} LIMIT 1")
    PageVersionEntity findById(@Param("id") String id);

    @Select("SELECT COALESCE(MAX(version_no), 0) FROM page_versions WHERE project_id = #{projectId}")
    int maxVersionNo(@Param("projectId") String projectId);

    @Insert("""
            INSERT INTO page_versions (id, project_id, version_no, document, source, created_by)
            VALUES (#{id}, #{projectId}, #{versionNo}, #{document}, #{source}, #{createdBy})
            """)
    int insert(PageVersionEntity version);
}
