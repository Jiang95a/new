package com.campus.server.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * application.yml 里 app.* 的配置。全部可通过环境变量覆盖（见 docs/.env.example）。
 */
@Data
@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private String webOrigin = "http://localhost:5173";
    private String publicBaseUrl = "http://localhost:5173/p";
    private String agentBaseUrl = "http://127.0.0.1:8000";
    private int agentTimeoutSeconds = 90;
    private Jwt jwt = new Jwt();
    private Upload upload = new Upload();

    @Data
    public static class Jwt {
        private String secret = "campus-diy-dev-secret-please-change-this-32bytes";
        private long accessTtlMinutes = 15;
        private long refreshTtlDays = 7;
    }

    @Data
    public static class Upload {
        private int maxMb = 10;
        private String dir = "./uploads";
    }
}
