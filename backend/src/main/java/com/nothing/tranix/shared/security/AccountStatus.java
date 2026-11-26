package com.nothing.tranix.shared.security;

import java.util.UUID;

/**
 * B-1603: lets security ask whether a token's user may still act. Implemented by the identity module (shared can not
 * depend on identity), checked on every request with an access token, so a suspension takes effect at once instead of
 * when the 15-minute access token expires.
 */
public interface AccountStatus {

    /** True when the user is suspended and every request with their token must be refused. */
    boolean isBlocked(UUID userId);
}
