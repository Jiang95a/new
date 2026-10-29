package com.campus.server.common;

import lombok.Getter;

/**
 * 业务异常。由 {@link GlobalExceptionHandler} 统一翻译成 {@code {error:{code,message,details}, requestId}}。
 */
@Getter
public class BizException extends RuntimeException {

    private final ErrorCode code;
    private final transient Object details;

    public BizException(ErrorCode code) {
        this(code, code.getDefaultMessage(), null);
    }

    public BizException(ErrorCode code, String message) {
        this(code, message, null);
    }

    public BizException(ErrorCode code, String message, Object details) {
        super(message);
        this.code = code;
        this.details = details;
    }

    public static BizException notFound(String message) {
        return new BizException(ErrorCode.NOT_FOUND, message);
    }

    public static BizException forbidden(String message) {
        return new BizException(ErrorCode.FORBIDDEN, message);
    }

    public static BizException invalid(String message) {
        return new BizException(ErrorCode.INVALID_INPUT, message);
    }

    public static BizException unauthenticated(String message) {
        return new BizException(ErrorCode.UNAUTHENTICATED, message);
    }
}
