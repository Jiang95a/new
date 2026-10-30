package com.campus.server.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.campus.server.entity.AiJobEntity;
import com.campus.server.entity.AiProposalEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;

@Mapper
public interface AiMapper {

    String JOB_COLUMNS = 
            "id, project_id, user_id, kind, status, client_request_id, input_payload, result_payload, "
          + "model_provider, model_name, error_code, error_message, started_at, finished_at, created_at ";

    String PROPOSAL_COLUMNS = 
            "id, job_id, project_id, base_version_id, base_revision, target, summary, candidate_document, "
          + "operations, rationale, risk, status, applied_revision, applied_by, applied_at, created_at ";

    // ---------------------------------------------------------------- ai_jobs

    @Insert("""
            INSERT INTO ai_jobs (id, project_id, user_id, kind, status, client_request_id,
                                 input_payload, model_provider, model_name)
            VALUES (#{id}, #{projectId}, #{userId}, #{kind}, #{status}, #{clientRequestId},
                    #{inputPayload}, #{modelProvider}, #{modelName})
            """)
    int insertJob(AiJobEntity job);

    @Select("SELECT " + JOB_COLUMNS + " FROM ai_jobs WHERE id = #{id} LIMIT 1")
    AiJobEntity findJob(@Param("id") String id);

    @Select("<script>SELECT " + JOB_COLUMNS + " FROM ai_jobs "
          + "WHERE user_id = #{userId} "
          + "<if test=\"clientRequestId != null and clientRequestId != ''\"> AND client_request_id = #{clientRequestId} </if>"
          + " ORDER BY created_at DESC LIMIT 1</script>")
    AiJobEntity findLatestJobByClientRequest(@Param("userId") String userId,
                                             @Param("clientRequestId") String clientRequestId);

    @Update("""
            UPDATE ai_jobs
               SET status = #{status},
                   result_payload = #{resultPayload},
                   error_code = #{errorCode},
                   error_message = #{errorMessage},
                   started_at = COALESCE(started_at, #{startedAt}),
                   finished_at = #{finishedAt}
             WHERE id = #{id}
            """)
    int updateJobResult(@Param("id") String id,
                        @Param("status") String status,
                        @Param("resultPayload") String resultPayload,
                        @Param("errorCode") String errorCode,
                        @Param("errorMessage") String errorMessage,
                        @Param("startedAt") LocalDateTime startedAt,
                        @Param("finishedAt") LocalDateTime finishedAt);

    // ---------------------------------------------------------------- ai_proposals

    @Insert("""
            <script>
            INSERT INTO ai_proposals (id, job_id, project_id, base_version_id, base_revision, target,
                                      summary, candidate_document, operations, rationale, risk, status)
            VALUES (#{id}, #{jobId}, #{projectId}, #{baseVersionId}, #{baseRevision}, #{target},
                    #{summary}, #{candidateDocument}, #{operations}, #{rationale}, #{risk}, #{status})
            </script>
            """)
    int insertProposal(AiProposalEntity proposal);

    @Select("SELECT " + PROPOSAL_COLUMNS + " FROM ai_proposals WHERE id = #{id} LIMIT 1")
    AiProposalEntity findProposal(@Param("id") String id);

    @Update("""
            UPDATE ai_proposals
               SET status = 'applied',
                   applied_revision = #{appliedRevision},
                   applied_by = #{appliedBy},
                   applied_at = CURRENT_TIMESTAMP
             WHERE id = #{id} AND status = 'proposed'
            """)
    int markApplied(@Param("id") String id,
                    @Param("appliedRevision") long appliedRevision,
                    @Param("appliedBy") String appliedBy);

    @Update("UPDATE ai_proposals SET status = 'stale' WHERE id = #{id} AND status = 'proposed'")
    int markStale(@Param("id") String id);
}
