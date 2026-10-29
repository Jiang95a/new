package com.campus.server.service;

import com.campus.server.config.AppProperties;
import com.campus.server.dto.Dtos;
import com.campus.server.support.Ids;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * /health：一次性告诉调用方「服务活着、数据库通不通、智能体通不通」。
 *
 * <p>数据库不通时服务仍然 200（status=degraded），这样前端能明确显示
 * 「后端起来了但没连上数据库」，比整个服务启动失败好排查得多。
 */
@Service
public class HealthService {

    private final JdbcTemplate jdbc;
    private final AiService aiService;
    private final AppProperties props;

    public HealthService(JdbcTemplate jdbc, AiService aiService, AppProperties props) {
        this.jdbc = jdbc;
        this.aiService = aiService;
        this.props = props;
    }

    public Dtos.HealthDto health() {
        Map<String, Object> database = new LinkedHashMap<>();
        boolean dbOk;
        try {
            Integer one = jdbc.queryForObject("SELECT 1", Integer.class);
            dbOk = one != null && one == 1;
            database.put("ok", dbOk);
            if (dbOk) {
                Integer tables = jdbc.queryForObject(
                        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()",
                        Integer.class);
                database.put("tables", tables);
                database.put("schema", jdbc.queryForObject("SELECT DATABASE()", String.class));
            }
        } catch (Exception ex) {
            dbOk = false;
            database.put("ok", false);
            database.put("error", ex.getMessage());
        }

        Map<String, Object> agent = new LinkedHashMap<>();
        agent.put("baseUrl", props.getAgentBaseUrl());
        agent.put("ok", aiService.agentAlive());

        String status = dbOk ? "ok" : "degraded";
        return new Dtos.HealthDto(status, "campus-server", database, agent, Ids.nowIso());
    }

    public boolean databaseAlive() {
        try {
            Integer one = jdbc.queryForObject("SELECT 1", Integer.class);
            return one != null && one == 1;
        } catch (Exception ex) {
            return false;
        }
    }
}
