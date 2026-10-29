package com.campus.server.security;

/**
 * 已登录用户的最小上下文。放在 ThreadLocal 里，由拦截器填充、请求结束清理。
 */
public record CurrentUser(String userId, String email) {

    private static final ThreadLocal<CurrentUser> HOLDER = new ThreadLocal<>();

    public static void set(CurrentUser user) {
        HOLDER.set(user);
    }

    public static CurrentUser get() {
        return HOLDER.get();
    }

    public static CurrentUser require() {
        CurrentUser user = HOLDER.get();
        if (user == null) {
            throw com.campus.server.common.BizException.unauthenticated("请先登录");
        }
        return user;
    }

    public static void clear() {
        HOLDER.remove();
    }
}
