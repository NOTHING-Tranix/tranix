package com.nothing.tranix.shared.integrations.fake;

import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.integrations.AadhaarVerifier;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Q-04 default: Aadhaar option hidden; PAN / Voter ID / licence are used instead. */
@Component
@ConditionalOnProperty(name = "tranix.integrations.aadhaar", havingValue = "disabled", matchIfMissing = true)
public class DisabledAadhaarVerifier implements AadhaarVerifier {

    @Override
    public boolean enabled() {
        return false;
    }

    @Override
    public Result verifyOfflineQr(String qrPayload) {
        throw new ApiException(ErrorCode.FORBIDDEN, "Aadhaar verification is not available yet");
    }
}
