package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.common.ErrorCode;
import com.campus.server.dto.Dtos;
import com.campus.server.entity.AuthSessionEntity;
import com.campus.server.entity.UserEntity;
import com.campus.server.mapper.AuthSessionMapper;
import com.campus.server.mapper.UserMapper;
import com.campus.server.security.CurrentUser;
import com.campus.server.security.JwtService;
import com.campus.server.support.Ids;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

/**
 * 注册 / 登录 / 刷新 / 登出 / 取当前用户。
 *
 * <p>Refresh Token 同时落库（auth_sessions 存 sha256），刷新时做轮换：
 * 旧 session 立刻 revoke，新 session 重新签发 —— 这样令牌泄露能被下一次刷新踩爆。
 */
@Service
public class AuthService {

    private final UserMapper userMapper;
    private final AuthSessionMapper sessionMapper;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserMapper userMapper, AuthSessionMapper sessionMapper,
                       JwtService jwtService, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.sessionMapper = sessionMapper;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public Dtos.AuthResponse register(Dtos.RegisterRequest request) {
        String email = request.email().trim().toLowerCase();
        if (userMapper.findByEmail(email) != null) {
            throw new BizException(ErrorCode.INVALID_INPUT, "该邮箱已注册");
        }
        UserEntity user = new UserEntity();
        user.setId(Ids.uuid());
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setDisplayName(request.displayName().trim());
        user.setStatus("active");
        try {
            userMapper.insert(user);
        } catch (DuplicateKeyException ex) {
            throw new BizException(ErrorCode.INVALID_INPUT, "该邮箱已注册");
        }
        return issueTokens(user, null);
    }

    @Transactional
    public Dtos.AuthResponse login(Dtos.LoginRequest request) {
        if (request.email() == null || request.password() == null) {
            throw BizException.invalid("邮箱和密码都不能为空");
        }
        String email = request.email().trim().toLowerCase();
        UserEntity user = userMapper.findByEmail(email);
        if (user == null || !passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            // 故意不区分「用户不存在」和「密码错误」，避免撞库探测
            throw BizException.unauthenticated("邮箱或密码不正确");
        }
        if (!"active".equals(user.getStatus())) {
            throw new BizException(ErrorCode.FORBIDDEN, "账号已被停用");
        }
        return issueTokens(user, null);
    }

    @Transactional
    public Dtos.AuthResponse refresh(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            throw BizException.unauthenticated("缺少 refreshToken");
        }
        var claims = jwtService.parse(refreshToken, JwtService.TYPE_REFRESH);
        String sessionId = claims.getId();
        AuthSessionEntity session = sessionMapper.findByTokenHash(Ids.sha256(refreshToken));
        if (session == null || session.getRevokedAt() != null || sessionId == null
                || !sessionId.equals(session.getId())) {
            throw BizException.unauthenticated("会话已失效，请重新登录");
        }
        if (session.getExpiresAt().isBefore(LocalDateTime.now(ZoneOffset.UTC))) {
            throw BizException.unauthenticated("会话已过期，请重新登录");
        }
        UserEntity user = userMapper.findById(claims.getSubject());
        if (user == null || !"active".equals(user.getStatus())) {
            throw BizException.unauthenticated("账号不可用");
        }
        // 轮换：旧 session 立刻作废
        sessionMapper.revoke(session.getId(), LocalDateTime.now(ZoneOffset.UTC));
        return issueTokens(user, null);
    }

    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }
        AuthSessionEntity session = sessionMapper.findByTokenHash(Ids.sha256(refreshToken));
        if (session != null) {
            sessionMapper.revoke(session.getId(), LocalDateTime.now(ZoneOffset.UTC));
        }
    }

    /**
     * 用 accessToken 登出。accessToken 是无状态的，但它里面有 session id（jti），
     * 把对应 session 吊销后，后续 /auth/me 之类的请求就会被拦下 —— 前端只传 Authorization
     * 头的场景（不带 refreshToken）也能正确登出。
     */
    @Transactional
    public void logoutByAccess(String accessToken) {
        if (accessToken == null || accessToken.isBlank()) {
            return;
        }
        String sessionId;
        try {
            sessionId = jwtService.parse(accessToken, JwtService.TYPE_ACCESS).getId();
        } catch (RuntimeException ex) {
            return; // token 本身不合法就当已登出，不报错
        }
        if (sessionId != null) {
            sessionMapper.revoke(sessionId, LocalDateTime.now(ZoneOffset.UTC));
        }
    }

    public Dtos.UserDto me() {
        CurrentUser current = CurrentUser.require();
        UserEntity user = userMapper.findById(current.userId());
        if (user == null) {
            throw BizException.unauthenticated("用户不存在");
        }
        return toDto(user);
    }

    private Dtos.AuthResponse issueTokens(UserEntity user, String userAgent) {
        // 先定 sessionId，accessToken 的 jti 与它绑定（拦截器据此判断会话是否已吊销）
        String sessionId = Ids.uuid();
        JwtService.Issued access = jwtService.issueAccess(user.getId(), user.getEmail(), sessionId);
        JwtService.Issued refresh = jwtService.issueRefresh(user.getId(), sessionId);

        AuthSessionEntity session = new AuthSessionEntity();
        session.setId(sessionId);
        session.setUserId(user.getId());
        session.setTokenHash(Ids.sha256(refresh.token()));
        session.setUserAgent(userAgent);
        session.setExpiresAt(LocalDateTime.ofInstant(refresh.expiresAt(), ZoneOffset.UTC));
        sessionMapper.insert(session);

        return new Dtos.AuthResponse(access.token(), refresh.token(), toDto(user));
    }

    private Dtos.UserDto toDto(UserEntity user) {
        return new Dtos.UserDto(user.getId(), user.getEmail(), user.getDisplayName(), user.getStatus());
    }
}
