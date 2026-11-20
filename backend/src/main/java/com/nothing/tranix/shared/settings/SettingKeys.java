package com.nothing.tranix.shared.settings;

/** Keys of {@code admin_setting} rows (seeded in V2__admin_setting_defaults.sql). */
public final class SettingKeys {

    public static final String POSTING_CHARGE_INR = "charges.posting_inr";
    public static final String TRIP_CHARGE_INR = "charges.trip_inr";
    public static final String TOPUP_CHIPS_INR = "wallet.topup_chips_inr";

    public static final String OTP_TTL_SECONDS = "otp.ttl_seconds";
    public static final String OTP_RESEND_SECONDS = "otp.resend_seconds";
    public static final String OTP_MAX_ATTEMPTS = "otp.max_attempts";
    public static final String OTP_LOCK_MINUTES = "otp.lock_minutes";
    public static final String GEOFENCE_METERS = "otp.geofence_meters";

    public static final String REVISION_LIMIT = "revision.limit";
    public static final String REVISION_RESPONSE_MINUTES = "revision.response_minutes";

    public static final String MATCHING_INITIAL_RADIUS_KM = "matching.initial_radius_km";
    public static final String MATCHING_BATCH_SIZE = "matching.batch_size";
    public static final String MATCHING_BATCH_INTERVAL_MINUTES = "matching.batch_interval_minutes";

    public static final String WISHLIST_MAX_ENTRIES = "wishlist.max_entries";
    public static final String WISHLIST_FIRST_MINUTES = "wishlist.first_minutes";
    public static final String WISHLIST_ONLY_NOTIFY_MINUTES = "wishlist.only_notify_minutes";
    public static final String WISHLIST_RELAXED_RADIUS_KM = "wishlist.relaxed_radius_km";

    public static final String TRUST_START_SCORE = "trust.start_score";

    public static final String ROUTE_SLOW_THRESHOLD_PCT = "route.slow_threshold_pct";
    public static final String ROUTE_FAST_THRESHOLD_PCT = "route.fast_threshold_pct";

    public static final String DOCUMENT_EXPIRY_REMINDER_DAYS = "documents.expiry_reminder_days";
    public static final String FILES_MAX_MB = "files.max_mb";
    public static final String LOCATION_RETENTION_DAYS = "location.retention_days";
    public static final String SUPPORT_REOPEN_DAYS = "support.reopen_days";

    public static final String GOODS_TYPES = "lists.goods_types";
    public static final String SUPPORTED_LANGUAGES = "lists.supported_languages";

    private SettingKeys() {
    }
}
