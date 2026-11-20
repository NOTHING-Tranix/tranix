package com.nothing.tranix.shared.integrations;

import java.util.Map;

import com.nothing.tranix.shared.types.Language;

/** Sends a DLT template SMS (real provider: Q-03). */
public interface SmsSender {

    /**
     * @param mobile      10-digit Indian mobile number (no +91)
     * @param templateKey our template key, e.g. {@code OTP_SIGN_IN}
     * @param params      template variables (may contain an OTP — never log them)
     */
    void send(String mobile, String templateKey, Map<String, String> params, Language language);
}
