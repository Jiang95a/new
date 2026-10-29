package com.campus.server.support;

import com.fasterxml.jackson.databind.JsonNode;
import org.apache.ibatis.type.MappedTypes;

/**
 * JSON 列 ⇄ JsonNode。draft_document / document / publish_settings 都用它。
 */
@MappedTypes(JsonNode.class)
public class JsonNodeTypeHandler extends JsonTypeHandler {

    @Override
    public void setNonNullParameter(java.sql.PreparedStatement ps, int i, Object parameter,
                                    org.apache.ibatis.type.JdbcType jdbcType) throws java.sql.SQLException {
        ps.setString(i, JsonUtil.toJson(parameter));
    }

    @Override
    public JsonNode getNullableResult(java.sql.ResultSet rs, String columnName) throws java.sql.SQLException {
        return readNode(rs.getString(columnName));
    }

    @Override
    public JsonNode getNullableResult(java.sql.ResultSet rs, int columnIndex) throws java.sql.SQLException {
        return readNode(rs.getString(columnIndex));
    }

    @Override
    public JsonNode getNullableResult(java.sql.CallableStatement cs, int columnIndex) throws java.sql.SQLException {
        return readNode(cs.getString(columnIndex));
    }
}
