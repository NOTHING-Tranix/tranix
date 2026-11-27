package com.nothing.tranix.shared.error;

import java.util.List;

import jakarta.validation.ConstraintViolationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.servlet.HandlerMapping;
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

    @ExceptionHandler(org.springframework.web.method.annotation.HandlerMethodValidationException.class)
    ResponseEntity<Problems.Problem> invalidParameters(org.springframework.web.method.annotation.HandlerMethodValidationException ex) {
        List<ApiException.FieldError> fields = ex.getParameterValidationResults().stream()
                .flatMap(r -> r.getResolvableErrors().stream().map(e -> new ApiException.FieldError(
                        r.getMethodParameter().getParameterName(), e.getDefaultMessage())))
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

    /** B-1615: wrong Content-Type (e.g. a file upload sent as JSON) is the client's mistake, not a server error. */
    @ExceptionHandler({HttpMediaTypeNotSupportedException.class, MultipartException.class})
    ResponseEntity<Problems.Problem> wrongContentType(Exception ex) {
        return respond(Problems.of(ErrorCode.VALIDATION_FAILED,
                "Send this request in the expected format (files as multipart/form-data with a 'file' part)"));
    }

    /** B-1615: the caller does not accept what this API returns (e.g. a CSV/PDF download asked for as JSON). */
    @ExceptionHandler(HttpMediaTypeNotAcceptableException.class)
    ResponseEntity<Problems.Problem> notAcceptable(HttpMediaTypeNotAcceptableException ex) {
        return respond(new Problems.Problem("about:blank", "Not acceptable", 406, ErrorCode.VALIDATION_FAILED.name(),
                "This API returns a file - send Accept: */* (or the file type)", List.of()));
    }

    /**
     * B-1615: two requests creating the same thing at the same moment (e.g. one mobile signing up twice). The database
     * keeps only one; the other gets a clear conflict instead of a crash. The message is not logged (it holds values).
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<Problems.Problem> conflict(DataIntegrityViolationException ex) {
        String msg = String.valueOf(ex.getMostSpecificCause().getMessage());
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("constraint \"([a-z0-9_]+)\"").matcher(msg);
        String constraint = m.find() ? m.group(1) : "unknown";
        log.warn("Data conflict on constraint {}", constraint);
        if ("identity_user_mobile_key".equals(constraint)) {
            return respond(Problems.of(ErrorCode.MOBILE_IN_USE, "This mobile number is already registered"));
        }
        return respond(Problems.of(ErrorCode.INVALID_STATE, "This was changed at the same moment by another request - please try again"));
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Problems.Problem> unexpected(Exception ex) {
        allowJsonError();
        log.error("Unhandled error", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .contentType(MediaType.APPLICATION_PROBLEM_JSON).body(Problems.internal(500));
    }

    /**
     * B-1602: one safe log line per refused request — the code, our own message and the names of the bad fields, never
     * the values the client sent (they can be mobiles or OTPs; hard rule 14). Spring's own "Resolved [...]" warning,
     * which prints rejected values, is switched off (spring.mvc.log-resolved-exception=false).
     */
    private static ResponseEntity<Problems.Problem> respond(Problems.Problem problem) {
        allowJsonError();
        if (log.isInfoEnabled()) {
            String fields = problem.fields() == null || problem.fields().isEmpty() ? ""
                    : " fields=" + problem.fields().stream().map(ApiException.FieldError::field).toList();
            log.info("Refused {} {}: {}{}", problem.status(), problem.code(), problem.detail(), fields);
        }
        return ResponseEntity.status(problem.status()).contentType(MediaType.APPLICATION_PROBLEM_JSON).body(problem);
    }

    /**
     * B-1615: APIs that return a file (CSV export, PDF statement) declare {@code produces}; without this an error from
     * them (403, 404…) could not be written as problem JSON and became a 500.
     */
    private static void allowJsonError() {
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes a) {
            a.getRequest().removeAttribute(HandlerMapping.PRODUCIBLE_MEDIA_TYPES_ATTRIBUTE);
        }
    }

    private static String lastNode(String path) {
        int dot = path.lastIndexOf('.');
        return dot >= 0 ? path.substring(dot + 1) : path;
    }
}
