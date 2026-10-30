package com.campus.server.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.campus.server.entity.UserEntity;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper {

    @Select("""
            SELECT id, email, password_hash, display_name, status, created_at, updated_at
              FROM users
             WHERE email = #{email}
             LIMIT 1
            """)
    UserEntity findByEmail(@Param("email") String email);

    @Select("""
            SELECT id, email, password_hash, display_name, status, created_at, updated_at
              FROM users
             WHERE id = #{id}
             LIMIT 1
            """)
    UserEntity findById(@Param("id") String id);

    @Insert("""
            INSERT INTO users (id, email, password_hash, display_name, status)
            VALUES (#{id}, #{email}, #{passwordHash}, #{displayName}, #{status})
            """)
    int insert(UserEntity user);

    @Update("UPDATE users SET display_name = #{displayName} WHERE id = #{id}")
    int updateDisplayName(@Param("id") String id, @Param("displayName") String displayName);
}
