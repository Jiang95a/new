package com.campus.server.config;

import com.campus.server.support.JsonNodeTypeHandler;
import com.fasterxml.jackson.databind.JsonNode;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.RestClient;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.time.Duration;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final AppProperties props;

    public WebConfig(AppProperties props) {
        this.props = props;
    }

    /**
     * 前端 5173 要带 Cookie 调 8080，必须 allowCredentials + 明确 origin（不能用 *）。
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns(props.getWebOrigin(), "http://127.0.0.1:5173")
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .exposedHeaders("X-Request-Id")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    /**
     * 把 JsonNode 的 TypeHandler 注册进 MyBatis，否则 Mapper 里但凡有个 JsonNode 参数
     * 都会在启动时报 "Type handler was null on parameter mapping"。
     */
    @Bean
    public ConfigurationCustomizer jsonNodeTypeHandlerCustomizer() {
        return configuration -> {
            JsonNodeTypeHandler handler = new JsonNodeTypeHandler();
            configuration.getTypeHandlerRegistry().register(handler);
        };
    }

    /** 调 agent 服务用的客户端，超时按 server/README.md 的约定给到 90 秒。 */
    @Bean
    public RestClient agentRestClient() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(5));
        factory.setReadTimeout(Duration.ofSeconds(props.getAgentTimeoutSeconds()));
        return RestClient.builder()
                .baseUrl(props.getAgentBaseUrl())
                .requestFactory(factory)
                .build();
    }
}
