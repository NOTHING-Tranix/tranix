package com.nothing.tranix.shared.error;

import org.springframework.http.HttpStatus;

/** Stable error codes from docs/api-contract.md §1. Names must match the contract exactly. */
public enum ErrorCode {
    VALIDATION_FAILED(HttpStatus.BAD_REQUEST, "Validation failed"),
    UNAUTHENTICATED(HttpStatus.UNAUTHORIZED, "Sign in required"),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "Token expired"),
    FORBIDDEN(HttpStatus.FORBIDDEN, "Not allowed"),
    NOT_VERIFIED(HttpStatus.FORBIDDEN, "Account not verified"),
    NOT_FOUND(HttpStatus.NOT_FOUND, "Not found"),
    OTP_INVALID(HttpStatus.BAD_REQUEST, "Wrong OTP"),
    OTP_EXPIRED(HttpStatus.BAD_REQUEST, "OTP expired"),
    OTP_LOCKED(HttpStatus.TOO_MANY_REQUESTS, "Too many wrong OTPs"),
    MOBILE_IN_USE(HttpStatus.CONFLICT, "Mobile number already registered"),
    INSUFFICIENT_BALANCE(HttpStatus.CONFLICT, "Insufficient wallet balance"),
    LOAD_TAKEN(HttpStatus.CONFLICT, "Taken by another driver"),
    INVALID_STATE(HttpStatus.CONFLICT, "Action not allowed in current status"),
    REVISION_LIMIT_REACHED(HttpStatus.CONFLICT, "Amount request limit reached"),
    REVISION_PENDING(HttpStatus.CONFLICT, "An amount request is already waiting"),
    ALLOCATION_CONFLICT(HttpStatus.CONFLICT, "Driver or truck already allocated"),
    WISHLIST_FULL(HttpStatus.CONFLICT, "Wish list is full"),
    WISHLIST_EMPTY(HttpStatus.CONFLICT, "No usable wish-list entries"),
    RATE_LIMITED(HttpStatus.TOO_MANY_REQUESTS, "Too many requests");

    private final HttpStatus status;
    private final String title;

    ErrorCode(HttpStatus status, String title) {
        this.status = status;
        this.title = title;
    }

    public HttpStatus status() {
        return status;
    }

    public String title() {
        return title;
    }
}
