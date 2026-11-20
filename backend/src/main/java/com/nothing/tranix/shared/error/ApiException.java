package com.nothing.tranix.shared.error;

import java.util.List;

/** Throw from any layer to return an RFC 7807 problem with a contract {@link ErrorCode}. */
public class ApiException extends RuntimeException {

    private final ErrorCode code;
    private final List<FieldError> fields;

    public ApiException(ErrorCode code) {
        this(code, null, List.of());
    }

    public ApiException(ErrorCode code, String detail) {
        this(code, detail, List.of());
    }

    public ApiException(ErrorCode code, String detail, List<FieldError> fields) {
        super(detail != null ? detail : code.title());
        this.code = code;
        this.fields = List.copyOf(fields);
    }

    public static ApiException notFound(String what) {
        return new ApiException(ErrorCode.NOT_FOUND, what + " not found");
    }

    public static ApiException invalidField(String field, String message) {
        return new ApiException(ErrorCode.VALIDATION_FAILED, message, List.of(new FieldError(field, message)));
    }

    public ErrorCode code() {
        return code;
    }

    public List<FieldError> fields() {
        return fields;
    }

    /** One entry of the problem's {@code fields} array. */
    public record FieldError(String field, String message) {
    }
}
