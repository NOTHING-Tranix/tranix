package com.nothing.tranix.identity.api;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

/** Read access to users for other modules. */
public interface UserDirectory {

    Optional<UserView> find(UUID userId);

    UserView get(UUID userId);

    Optional<UserView> findByMobile(String mobile);

    /** FCM tokens of the user's devices. */
    List<String> fcmTokens(UUID userId);

    /** Role-profile fields as saved (e.g. orgName, licenceNumber). Empty map if none. */
    Map<String, Object> roleProfile(UUID userId);

    /** Sets the cached trust score (written only by the trust module). */
    void updateTrustScore(UUID userId, BigDecimal score);

    record UserView(UUID id, String name, String mobile, Role role, Language language,
                    VerificationStatus verificationStatus, BigDecimal trustScore, boolean suspended,
                    UUID photoFileId) {

        public boolean verified() {
            return verificationStatus == VerificationStatus.VERIFIED && !suspended;
        }
    }

    /** M9 wish list: verified, not suspended Organizations whose name or code matches {@code q}. */
    List<OrgView> searchOrganizations(String q, int limit);

    record OrgView(UUID orgId, String orgName, String orgCode, String district, BigDecimal trustScore) {
    }

    /** Organization code shown to shippers (D-30, assumed): {@code ORG-} + first 6 hex digits of the org id. */
    static String orgCode(UUID orgId) {
        return "ORG-" + orgId.toString().substring(0, 6).toUpperCase(java.util.Locale.ROOT);
    }
}
