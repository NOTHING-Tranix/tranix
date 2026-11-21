package com.nothing.tranix.trips.api;

import java.util.Map;
import java.util.UUID;

/** M14 admin actions on trips (callers audit them). */
public interface TripAdmin {

    /** Completes the pickup (LOCATION_REACHED) or delivery (ARRIVED_DESTINATION) step without the OTP; old codes are invalidated. */
    Map<String, Object> otpOverride(UUID loadId, String purpose, UUID adminId);

    /** Location exception review: OK or FLAGGED with a note. */
    Map<String, Object> reviewLocationException(UUID exceptionId, String decision, String note);
}
