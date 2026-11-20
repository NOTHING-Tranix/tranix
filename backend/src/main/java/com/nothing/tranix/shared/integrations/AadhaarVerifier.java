package com.nothing.tranix.shared.integrations;

/**
 * UIDAI offline verification / DigiLocker (D-03; provider: Q-04). Implementations return only the last 4 digits and
 * the name on record — never the full number or image.
 */
public interface AadhaarVerifier {

    /** False until a provider is configured; the app hides the Aadhaar option. */
    boolean enabled();

    Result verifyOfflineQr(String qrPayload);

    record Result(boolean verified, String last4, String nameOnRecord) {
    }
}
