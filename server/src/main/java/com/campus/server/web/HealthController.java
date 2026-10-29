package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.service.HealthService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 健康检查。不需要登录，用来确认「后端起来了没有、数据库通不通、agent 通不通」。
 *
 * <p>前端 / 演示脚本第一件事就是打这里（见 docs/团队综合开发文档.md 验收顺序第 1 步）。
 */
@RestController
public class HealthController {

    private final HealthService healthService;

    public HealthController(HealthService healthService) {
        this.healthService = healthService;
    }

    @GetMapping("/health")
    public ApiResponse.Envelope<com.campus.server.dto.Dtos.HealthDto> health() {
        return ApiResponse.ok(healthService.health());
    }

    /** 极简版，给容器/脚本探活用，不碰数据库。 */
    @GetMapping("/ping")
    public Map<String, Object> ping() {
        return Map.of("ok", true);
    }
}
