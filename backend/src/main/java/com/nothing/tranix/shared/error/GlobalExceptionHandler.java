package com.nothing.tranix.shared.error;

import java.util.List;

import jakarta.validation.ConstraintViolationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

/** Maps every exception to an RFC 7807 problem with a contract {@code code}. */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ApiException.class)
    ResponseEntity<Problems.Problem> api(ApiException ex) {
        return respond(Problems.of(ex.code(), ex.getMessage(), ex.fields()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<Problems.Problem> invalidBody(MethodArgumentNotValidException ex) {
        List<ApiException.FieldError> fields = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> new ApiException.FieldError(e.getField(), e.getDefaultMessage()))
                .toList();
        return respond(Problems.of(ErrorCode.VALIDATION_FAILED, "Some fields are invalid", fields));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    ResponseEntity<Problems.Problem> invalidParams(ConstraintViolationException ex) {
        List<ApiException.FieldError> fields = ex.getConstraintViolations().stream()
                .map(v -> new ApiException.FieldError(lastNode(v.getPropertyPath().toString()), v.getMessage()))
                .toList();
        return respond(Problems.of(ErrorCode.VALIDATION_FAILED, "Some fields are invalid", fields));
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class,
            MissingServletRequestParameterException.class, MissingServletRequestPartException.class})
    ResponseEntity<Problems.Problem> badRequest(Exception ex) {
        return respond(Problems.of(ErrorCode.VALIDATION_FAILED, "Request is malformed or incomplete"));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    ResponseEntity<Problems.Problem> tooLarge(MaxUploadSizeExceededException ex) {
        return respond(Problems.of(ErrorCode.VALIDATION_FAILED, "File is larger than 10 MB",
                List.of(new ApiException.FieldError("file", "File is larger than 10 MB"))));
    }

    @ExceptionHandler(NoResourceFoundException.class)
    ResponseEntity<Problems.Problem> noResource(NoResourceFoundException ex) {
        return respond(Problems.of(ErrorCode.NOT_FOUND, "Not found"));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    ResponseEntity<Problems.Problem> method(HttpRequestMethodNotSupportedException ex) {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .contentType(MediaType.APPLICATION_PROBLEM_JSON).body(Problems.internal(405));
    }

    @ExceptionHandler(AccessDeniedException.class)
    ResponseEntity<Problems.Problem> denied(AccessDeniedException ex) {
        return respond(Problems.of(ErrorCode.FORBIDDEN, "You can't do this"));
    }

    @ExceptionHandler(AuthenticationException.class)
    ResponseEntity<Problems.Problem> unauthenticated(AuthenticationException ex) {
        return respond(Problems.of(ErrorCode.UNAUTHENTICATED, "Sign in required"));
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Problems.Problem> unexpected(Exception ex) {
        log.error("Unhandled error", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .contentType(MediaType.APPLICATION_PROBLEM_JSON).body(Problems.internal(500));
    }

    private static ResponseEntity<Problems.Problem> respond(Problems.Problem problem) {
        return ResponseEntity.status(problem.status()).contentType(MediaType.APPLICATION_PROBLEM_JSON).body(problem);
    }

    private static String lastNode(String path) {
        int dot = path.lastIndexOf('.');
        return dot >= 0 ? path.substring(dot + 1) : path;
    }
}
