package com.campus.server;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * 校园轻活动 AI DIY 工坊 —— 业务后端入口。
 *
 * <p>对外契约以 {@code docs/api/openapi.yaml} 为准，三端（web / server / agent）共用。
 * 服务端口 8080，统一前缀 {@code /api/v1}（见 application.yml 的 context-path）。
 */
@SpringBootApplication
@ConfigurationPropertiesScan("com.campus.server.config")
@MapperScan("com.campus.server.mapper")
public class ServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServerApplication.class, args);
    }
}
