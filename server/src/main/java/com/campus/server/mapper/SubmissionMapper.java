package com.campus.server.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.campus.server.entity.FormSubmissionEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SubmissionMapper {

    String COLUMNS = 
            "id, project_id, version_id, page_id, form_component_id, answers, "
          + "idempotency_key, submitter_hash, status, submitted_at ";

    @Insert("""
            INSERT INTO form_submissions (id, project_id, version_id, page_id, form_component_id,
                                          answers, idempotency_key, submitter_hash, status)
            VALUES (#{id}, #{projectId}, #{versionId}, #{pageId}, #{formComponentId},
                    #{answers}, #{idempotencyKey}, #{submitterHash}, #{status})
            """)
    int insert(FormSubmissionEntity submission);

    @Select("SELECT " + COLUMNS + " FROM form_submissions "
          + "WHERE project_id = #{projectId} AND idempotency_key = #{idempotencyKey} LIMIT 1")
    FormSubmissionEntity findByIdempotencyKey(@Param("projectId") String projectId,
                                             @Param("idempotencyKey") String idempotencyKey);

    @Select("<script>SELECT " + COLUMNS + " FROM form_submissions "
          + "WHERE project_id = #{projectId} "
          + "<if test=\"status != null and status != ''\"> AND status = #{status} </if>"
          + " ORDER BY submitted_at DESC, id ASC LIMIT #{limit} OFFSET #{offset}</script>")
    List<FormSubmissionEntity> page(@Param("projectId") String projectId,
                                    @Param("status") String status,
                                    @Param("limit") int limit,
                                    @Param("offset") int offset);

    @Select("""
            <script>
            SELECT COUNT(*) FROM form_submissions
             WHERE project_id = #{projectId}
            <if test="status != null and status != ''">
               AND status = #{status}
            </if>
            </script>
            """)
    long count(@Param("projectId") String projectId, @Param("status") String status);

    @Select("SELECT COUNT(*) FROM form_submissions WHERE project_id = #{projectId} AND status = 'valid'")
    long countValid(@Param("projectId") String projectId);
}
