package com.campus.server.web;

import com.campus.server.common.ApiResponse;
import com.campus.server.common.BizException;
import com.campus.server.dto.Dtos;
import com.campus.server.service.AuthService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;

/**
 * 认证。
 *
 * <p>双轨：body 里返回 accessToken / refreshToken（方便后端自测、脚本调用），
 * 同时把 refreshToken 写进 HttpOnly Cookie（浏览器端更安全）。
 * 前端当前是纯本地存储模式，接后端时按本项目实际需要选其中一种即可。
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    private static final String REFRESH_COOKIE = "campus_refresh";

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResponse.Envelope<Dtos.AuthResponse> register(@Valid @RequestBody Dtos.RegisterRequest request,
                                                            HttpServletResponse response) {
        Dtos.AuthResponse result = authService.register(request);
        setRefreshCookie(response, result.refreshToken());
        return ApiResponse.ok(result);
    }

    @PostMapping("/login")
    public ApiResponse.Envelope<Dtos.AuthResponse> login(@Valid @RequestBody Dtos.LoginRequest request,
                                                         HttpServletResponse response) {
        Dtos.AuthResponse result = authService.login(request);
        setRefreshCookie(response, result.refreshToken());
        return ApiResponse.ok(result);
    }

    @PostMapping("/refresh")
    public ApiResponse.Envelope<Dtos.AuthResponse> refresh(@RequestBody(required = false) Dtos.RefreshRequest body,
                                                           HttpServletResponse response) {
        String token = body != null && body.refreshToken() != null && !body.refreshToken().isBlank()
                ? body.refreshToken()
                : readRefreshCookie(response);
        if (token == null || token.isBlank()) {
            throw BizException.unauthenticated("缺少 refreshToken");
        }
        Dtos.AuthResponse result = authService.refresh(token);
        setRefreshCookie(response, result.refreshToken());
        return ApiResponse.ok(result);
    }

    @PostMapping("/logout")
    public ApiResponse.Envelope<java.util.Map<String, Object>> logout(
            @RequestBody(required = false) Dtos.RefreshRequest body,
            jakarta.servlet.http.HttpServletRequest request,
            HttpServletResponse response) {
        String token = null;
        if (body != null && body.refreshToken() != null && !body.refreshToken().isBlank()) {
            token = body.refreshToken();
        } else {
            // 前端多数情况下只带 Authorization 头，把 accessToken 对应的会话一起吊销，
            // 否则「登出」之后旧 token 还能继续用 —— 这是验收里实测暴露出来的问题。
            token = readRefreshCookie(request);
            String auth = request.getHeader("Authorization");
            String access = (auth != null && auth.startsWith("Bearer ")) ? auth.substring(7).trim() : null;
            if (token == null && access != null) {
                authService.logoutByAccess(access);
                token = "";
            }
        }
        if (token != null && !token.isEmpty()) {
            authService.logout(token);
        }
        clearRefreshCookie(response);
        return ApiResponse.ok(java.util.Map.of("ok", true));
    }

    @GetMapping("/me")
    public ApiResponse.Envelope<Dtos.UserDto> me() {
        return ApiResponse.ok(authService.me());
    }

    // ================================================================ Cookie

    private void setRefreshCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(REFRESH_COOKIE, token == null ? "" : token)
                .httpOnly(true)
                .path("/api/v1/auth")
                .maxAge(Duration.ofDays(7))
                .sameSite("Lax")
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    private void clearRefreshCookie(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from(REFRESH_COOKIE, "")
                .httpOnly(true)
                .path("/api/v1/auth")
                .maxAge(Duration.ZERO)
                .sameSite("Lax")
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    private String readRefreshCookie(HttpServletResponse response) {
        // 用 HttpServletRequest 读更直接，这里由框架注入会更干净；为保持签名简单，交给拦截器层不重要，
        // 直接用 RequestContextHolder 取当前请求。
        org.springframework.web.context.request.ServletRequestAttributes attrs =
                (org.springframework.web.context.request.ServletRequestAttributes)
                        org.springframework.web.context.request.RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return null;
        }
        return readRefreshCookie(attrs.getRequest());
    }

    private String readRefreshCookie(jakarta.servlet.http.HttpServletRequest request) {
        jakarta.servlet.http.Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }
        for (jakarta.servlet.http.Cookie cookie : cookies) {
            if (REFRESH_COOKIE.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }
}
