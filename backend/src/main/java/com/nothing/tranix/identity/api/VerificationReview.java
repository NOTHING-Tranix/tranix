package com.nothing.tranix.identity.api;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Admin verification queue and decisions (B-203). */
public interface VerificationReview {

    enum Tab { DRIVER, VEHICLE, FARMER_NETWORK, ORGANIZATION, IDENTITY }

    List<Map<String, Object>> queue(Tab tab);

    DocumentRegistry.DocumentView review(UUID adminId, UUID documentId, boolean approve, String reason);
}
