package com.campus.server.support;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

/**
 * MySQL JSON 列 ⇄ Java 对象。
 *
 * <p>用例：
 * <ul>
 *   <li>{@code Map<String,Object>} / {@code List<Object>} —— draft_document、operations 等
 *   <li>需要时也可用于自定义 POJO，只要传 Class 即可（见 {@link JsonOf} 的替代写法）
 * </ul>
 *
 * <p>写入时用 {@code CAST(? AS JSON)}，读取时 MySQL 驱动返回 String，直接交给 Jackson。
 */
@MappedTypes({Object.class})
public class JsonTypeHandler extends BaseTypeHandler<Object> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Object parameter, JdbcType jdbcType)
            throws SQLException {
        ps.setString(i, JsonUtil.toJson(parameter));
    }

    @Override
    public Object getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return parse(rs.getString(columnName));
    }

    @Override
    public Object getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return parse(rs.getString(columnIndex));
    }

    @Override
    public Object getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return parse(cs.getString(columnIndex));
    }

    private Object parse(String json) {
        if (json == null || json.isBlank()) {
            return null;
        }
        return JsonUtil.fromJson(json, Object.class);
    }

    /** 供 Mapper 内部做通用 JSON → String 转换时复用。 */
    public static String write(Object value) {
        return JsonUtil.toJson(value);
    }

    /** 供 Mapper 内部做通用 String → JsonNode 转换时复用。 */
    public static com.fasterxml.jackson.databind.JsonNode readNode(String json) {
        if (json == null || json.isBlank()) {
            return JsonUtil.mapper().createObjectNode();
        }
        return JsonUtil.fromJson(json, com.fasterxml.jackson.databind.JsonNode.class);
    }

    /** MySQL 的 JSON 列在 JDBC 里按 VARCHAR 处理，这里显式声明避免踩方言坑。 */
    public static final JdbcType JSON_JDBC = JdbcType.VARCHAR;

    static {
        if (JSON_JDBC.TYPE_CODE != Types.VARCHAR) {
            throw new IllegalStateException("JSON 列的 JDBC 类型假设不成立");
        }
    }
}
