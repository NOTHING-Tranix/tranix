package com.nothing.tranix.shared.error;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

/** Builds problem bodies in the exact shape of docs/api-contract.md §1. */
public final class Problems {

    private Problems() {
    }

    public static Problem of(ErrorCode code, String detail, List<ApiException.FieldError> fields) {
        return new Problem("about:blank", code.title(), code.status().value(), code.name(), detail,
                fields == null ? List.of() : List.copyOf(fields));
    }

    public static Problem of(ErrorCode code, String detail) {
        return of(code, detail, List.of());
    }

    /** Error without a contract code (the app shows a generic message). */
    public static Problem internal(int status) {
        return new Problem("about:blank", "Something went wrong", status, null, null, List.of());
    }

    /**
     * RFC 7807 problem: {@code {type, title, status, code, detail, fields:[{field, message}]}}. Served as
     * {@code application/problem+json}.
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Problem(String type, String title, int status, String code, String detail,
                          List<ApiException.FieldError> fields) {
    }
}
