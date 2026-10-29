package com.campus.server.mapper;

import com.campus.server.entity.AuthSessionEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;

public interface AuthSessionMapper {

    @Insert("""
            INSERT INTO auth_sessions (id, user_id, token_hash, user_agent, expires_at)
            VALUES (#{id}, #{userId}, #{tokenHash}, #{userAgent}, #{expiresAt})
            """)
    int insert(AuthSessionEntity session);

    @Select("""
            SELECT id, user_id, token_hash, user_agent, expires_at, revoked_at, created_at
              FROM auth_sessions
             WHERE token_hash = #{tokenHash}
             LIMIT 1
            """)
    AuthSessionEntity findByTokenHash(@Param("tokenHash") String tokenHash);

    @Select("""
            SELECT id, user_id, token_hash, user_agent, expires_at, revoked_at, created_at
              FROM auth_sessions
             WHERE id = #{id}
             LIMIT 1
            """)
    AuthSessionEntity findById(@Param("id") String id);

    @Update("UPDATE auth_sessions SET revoked_at = #{revokedAt} WHERE id = #{id} AND revoked_at IS NULL")
    int revoke(@Param("id") String id, @Param("revokedAt") LocalDateTime revokedAt);

    @Update("UPDATE auth_sessions SET revoked_at = #{revokedAt} WHERE user_id = #{userId} AND revoked_at IS NULL")
    int revokeAllByUser(@Param("userId") String userId, @Param("revokedAt") LocalDateTime revokedAt);

    @Update("UPDATE auth_sessions SET revoked_at = #{revokedAt} WHERE id = #{id}")
    int forceRevoke(@Param("id") String id, @Param("revokedAt") LocalDateTime revokedAt);
}
