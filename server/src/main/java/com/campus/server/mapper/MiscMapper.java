package com.campus.server.mapper;

import com.campus.server.entity.MiscEntities.ActivityEventEntity;
import com.campus.server.entity.MiscEntities.ExportJobEntity;
import com.campus.server.entity.ProjectAssetEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

public interface MiscMapper {

    // ---------------------------------------------------------------- project_assets

    String ASSET_COLUMNS = 
            "id, owner_id, project_id, object_key, mime_type, size_bytes, sha256, "
          + "width, height, status, created_at ";

    @Insert("""
            INSERT INTO project_assets (id, owner_id, project_id, object_key, mime_type,
                                        size_bytes, sha256, width, height, status)
            VALUES (#{id}, #{ownerId}, #{projectId}, #{objectKey}, #{mimeType},
                    #{sizeBytes}, #{sha256}, #{width}, #{height}, #{status})
            """)
    int insertAsset(ProjectAssetEntity asset);

    @Select("SELECT " + ASSET_COLUMNS + " FROM project_assets WHERE id = #{id} LIMIT 1")
    ProjectAssetEntity findAsset(@Param("id") String id);

    @Select("SELECT " + ASSET_COLUMNS + " FROM project_assets WHERE object_key = #{objectKey} LIMIT 1")
    ProjectAssetEntity findAssetByKey(@Param("objectKey") String objectKey);

    // ---------------------------------------------------------------- activity_events

    @Insert("""
            INSERT INTO activity_events (project_id, event_type, page_id, metadata)
            VALUES (#{projectId}, #{eventType}, #{pageId}, #{metadata})
            """)
    int insertEvent(ActivityEventEntity event);

    @Select("""
            SELECT COUNT(*) FROM activity_events
             WHERE project_id = #{projectId} AND event_type = #{eventType}
            """)
    long countEvent(@Param("projectId") String projectId, @Param("eventType") String eventType);

    @Select("""
            SELECT COUNT(DISTINCT page_id) FROM activity_events
             WHERE project_id = #{projectId} AND event_type = 'public_page_view'
            """)
    long countDistinctViewedPages(@Param("projectId") String projectId);

    @Select("""
            SELECT DATE(submitted_at) AS d, COUNT(*) AS c
              FROM form_submissions
             WHERE project_id = #{projectId}
             GROUP BY DATE(submitted_at)
             ORDER BY d
            """)
    List<java.util.Map<String, Object>> submissionsByDay(@Param("projectId") String projectId);

    /**
     * 浏览埋点按天聚合，用于补足 byDay 里「只有提交、没有浏览」的空白天。
     * 返回列：d（日期）、c（次数）。
     */
    @Select("""
            SELECT DATE(occurred_at) AS d, COUNT(*) AS c
              FROM activity_events
             WHERE project_id = #{projectId} AND event_type = 'public_page_view'
             GROUP BY DATE(occurred_at)
             ORDER BY d
            """)
    List<java.util.Map<String, Object>> viewsByDay(@Param("projectId") String projectId);

    /** 分事件类型的汇总计数，用于看板上的分项卡片。 */
    @Select("""
            SELECT event_type AS t, COUNT(*) AS c
              FROM activity_events
             WHERE project_id = #{projectId}
             GROUP BY event_type
            """)
    List<java.util.Map<String, Object>> eventsGrouped(@Param("projectId") String projectId);

    /** 原始事件列表（分页），给「明细」页用。 */
    @Select("""
            <script>
            SELECT id, project_id, event_type, page_id, metadata, occurred_at
              FROM activity_events
             WHERE project_id = #{projectId}
             <if test="eventType != null and eventType != ''"> AND event_type = #{eventType} </if>
             ORDER BY occurred_at DESC, id DESC
             LIMIT #{limit} OFFSET #{offset}
            </script>
            """)
    List<com.campus.server.entity.MiscEntities.ActivityEventEntity> listEvents(@Param("projectId") String projectId,
                                                                              @Param("eventType") String eventType,
                                                                              @Param("limit") int limit,
                                                                              @Param("offset") int offset);

    @Select("""
            <script>
            SELECT COUNT(*) FROM activity_events
             WHERE project_id = #{projectId}
             <if test="eventType != null and eventType != ''"> AND event_type = #{eventType} </if>
            </script>
            """)
    long countEvents(@Param("projectId") String projectId, @Param("eventType") String eventType);

    // ---------------------------------------------------------------- export_jobs

    String EXPORT_COLUMNS = 
            "id, project_id, requested_by, status, filters, object_key, error_message, "
          + "expires_at, created_at, finished_at ";

    @Insert("""
            INSERT INTO export_jobs (id, project_id, requested_by, status, filters, expires_at)
            VALUES (#{id}, #{projectId}, #{requestedBy}, #{status}, #{filters}, #{expiresAt})
            """)
    int insertExportJob(ExportJobEntity job);

    @Select("SELECT " + EXPORT_COLUMNS + " FROM export_jobs WHERE id = #{id} LIMIT 1")
    ExportJobEntity findExportJob(@Param("id") String id);

    @Update("""
            UPDATE export_jobs
               SET status = #{status}, object_key = #{objectKey}, error_message = #{errorMessage},
                   finished_at = #{finishedAt}
             WHERE id = #{id}
            """)
    int updateExportJob(@Param("id") String id,
                        @Param("status") String status,
                        @Param("objectKey") String objectKey,
                        @Param("errorMessage") String errorMessage,
                        @Param("finishedAt") LocalDateTime finishedAt);
}
