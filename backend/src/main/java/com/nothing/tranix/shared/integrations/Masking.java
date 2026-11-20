package com.nothing.tranix.shared.integrations;

/** Masks personal data before it reaches logs (CLAUDE.md hard rule 14). */
public final class Masking {

    private Masking() {
    }

    /** {@code 9876543210} → {@code ******3210}. */
    public static String mobile(String mobile) {
        if (mobile == null || mobile.length() < 4) {
            return "****";
        }
        return "*".repeat(mobile.length() - 4) + mobile.substring(mobile.length() - 4);
    }
}
