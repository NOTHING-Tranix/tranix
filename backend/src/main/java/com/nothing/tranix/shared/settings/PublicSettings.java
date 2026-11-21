package com.nothing.tranix.shared.settings;

import java.util.List;

/** {@code GET /settings/public} body — docs/api-contract.md §12, field names exactly as in the contract. */
public record PublicSettings(
        int postingChargeInr,
        int tripChargeInr,
        List<Integer> topupChips,
        int otpTtlSeconds,
        int otpResendSeconds,
        int revisionLimit,
        int revisionResponseMinutes,
        int geofenceMeters,
        int wishlistMax,
        int wishlistFirstMinutes,
        int wishlistOnlyNotifyMinutes,
        List<String> goodsTypes,
        List<String> vehicleTypes,
        List<String> ticketTypes,
        List<String> rejectReasons,
        List<String> supportedLanguages,
        List<String> ratingTags,
        boolean aadhaarEnabled) {
}
