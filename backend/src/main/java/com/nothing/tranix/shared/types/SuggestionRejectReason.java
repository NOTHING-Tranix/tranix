package com.nothing.tranix.shared.types;

/** Reasons for {@code POST /driver/suggestions/{loadId}/reject} (docs/api-contract.md §8). */
public enum SuggestionRejectReason {
    TOO_FAR, LOW_AMOUNT, WRONG_TRUCK, OTHER
}
