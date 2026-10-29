package com.campus.server.common;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 全局异常翻译。保证任何异常都返回契约里的 JSON，而不是 Spring 默认的 white-label 页面。
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BizException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onBiz(BizException ex) {
        log.debug("业务异常 {}: {}", ex.getCode(), ex.getMessage());
        return ResponseEntity.status(ex.getCode().getStatus())
                .body(ApiResponse.error(ex.getCode(), ex.getMessage(), ex.getDetails()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onInvalid(MethodArgumentNotValidException ex) {
        Map<String, String> fields = new LinkedHashMap<>();
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            fields.putIfAbsent(error.getField(), error.getDefaultMessage());
        }
        return ResponseEntity.status(ErrorCode.INVALID_INPUT.getStatus())
                .body(ApiResponse.error(ErrorCode.INVALID_INPUT, ErrorCode.INVALID_INPUT.getDefaultMessage(), fields));
    }

    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onBind(BindException ex) {
        Map<String, String> fields = new LinkedHashMap<>();
        ex.getBindingResult().getFieldErrors()
                .forEach(error -> fields.putIfAbsent(error.getField(), error.getDefaultMessage()));
        return ResponseEntity.status(ErrorCode.INVALID_INPUT.getStatus())
                .body(ApiResponse.error(ErrorCode.INVALID_INPUT, ErrorCode.INVALID_INPUT.getDefaultMessage(), fields));
    }

    @ExceptionHandler({
            HttpMessageNotReadableException.class,
            MethodArgumentTypeMismatchException.class,
            MissingServletRequestParameterException.class,
            IllegalArgumentException.class
    })
    public ResponseEntity<ApiResponse.ErrorEnvelope> onBadRequest(Exception ex) {
        return ResponseEntity.status(ErrorCode.INVALID_INPUT.getStatus())
                .body(ApiResponse.error(ErrorCode.INVALID_INPUT, ex.getMessage(), null));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onTooLarge(MaxUploadSizeExceededException ex) {
        return ResponseEntity.status(ErrorCode.FILE_TOO_LARGE.getStatus())
                .body(ApiResponse.error(ErrorCode.FILE_TOO_LARGE, ErrorCode.FILE_TOO_LARGE.getDefaultMessage(), null));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onMethod(HttpRequestMethodNotSupportedException ex) {
        return ResponseEntity.status(405)
                .body(ApiResponse.error(ErrorCode.INVALID_INPUT, "不支持的请求方法: " + ex.getMethod(), null));
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onNoResource(NoResourceFoundException ex) {
        return ResponseEntity.status(ErrorCode.NOT_FOUND.getStatus())
                .body(ApiResponse.error(ErrorCode.NOT_FOUND, "接口不存在: " + ex.getResourcePath(), null));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse.ErrorEnvelope> onUnknown(Exception ex, HttpServletRequest request) {
        log.error("未处理异常 {} {}", request.getMethod(), request.getRequestURI(), ex);
        return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.getStatus())
                .body(ApiResponse.error(ErrorCode.INTERNAL_ERROR, ErrorCode.INTERNAL_ERROR.getDefaultMessage(), null));
    }
}
