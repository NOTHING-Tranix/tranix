package com.nothing.tranix.fleet.api;

import java.util.Map;
import java.util.UUID;

/** Lets other modules add fields to {@code GET /driver/home} (matching -> suggestionsCount). */
public interface DriverHomeContributor {

    void contribute(UUID driverId, Map<String, Object> home);
}
