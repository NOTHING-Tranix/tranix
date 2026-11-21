package com.nothing.tranix.identity.internal;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.identity.api.MeContributor;
import com.nothing.tranix.identity.api.UserEvents;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.files.FileService;
import com.nothing.tranix.shared.integrations.Masking;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.OtpPurpose;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Sign-up/sign-in (B-103…B-106) and profile (B-108…B-112). */
@Service
public class IdentityService {

    private final UserRepository users;
    private final AddressRepository addresses;
    private final RoleProfileRepository roleProfiles;
    private final DeviceRepository devices;
    private final OtpService otp;
    private final TokenService tokens;
    private final RoleProfiles roleProfileRules;
    private final UserDocuments documents;
    private final FileService files;
    private final Settings settings;
    private final AuditLog audit;
    private final ApplicationEventPublisher events;
    private final ObjectProvider<MeContributor> contributors;
    private final Clock clock;
    /** B-1201: when set, only these mobiles may sign in as ADMIN (tranix.admin.mobiles). */
    private final java.util.Set<String> adminMobiles;

    IdentityService(UserRepository users, AddressRepository addresses, RoleProfileRepository roleProfiles,
                    DeviceRepository devices, OtpService otp, TokenService tokens, RoleProfiles roleProfileRules,
                    UserDocuments documents, FileService files, Settings settings, AuditLog audit,
                    ApplicationEventPublisher events, ObjectProvider<MeContributor> contributors, Clock clock,
                    @org.springframework.beans.factory.annotation.Value("${tranix.admin.mobiles:}") String adminMobiles) {
        this.adminMobiles = java.util.Arrays.stream(adminMobiles.split(",")).map(String::trim).filter(s -> !s.isEmpty())
                .collect(java.util.stream.Collectors.toUnmodifiableSet());
        this.users = users;
        this.addresses = addresses;
        this.roleProfiles = roleProfiles;
        this.devices = devices;
        this.otp = otp;
        this.tokens = tokens;
        this.roleProfileRules = roleProfileRules;
        this.documents = documents;
        this.files = files;
        this.settings = settings;
        this.audit = audit;
        this.events = events;
        this.contributors = contributors;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- auth

    /** Always succeeds for SIGN_IN so accounts can't be enumerated; no SMS is sent for unknown numbers. */
    @Transactional
    public void sendOtp(String mobile, OtpPurpose purpose) {
        switch (purpose) {
            case SIGN_UP -> otp.send(mobile, purpose, null, Language.en);
            case SIGN_IN -> users.findByMobile(mobile)
                    .ifPresent(u -> otp.send(mobile, purpose, u.getId(), u.getLanguage()));
            default -> throw ApiException.invalidField("purpose", "Use SIGN_UP or SIGN_IN");
        }
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResult signUp(String mobile, String code, String name, Role role, Language language, String deviceId) {
        if (role == Role.ADMIN) {
            throw ApiException.invalidField("role", "This role can not sign up");
        }
        if (users.existsByMobile(mobile)) {
            throw new ApiException(ErrorCode.MOBILE_IN_USE);
        }
        otp.verify(mobile, OtpPurpose.SIGN_UP, code);
        Instant now = Instant.now(clock);
        User user = users.saveAndFlush(new User(mobile, name.trim(), role, language,
                BigDecimal.valueOf(settings.getInt(SettingKeys.TRUST_START_SCORE)), now));
        recompute(user);
        events.publishEvent(new UserEvents.UserRegistered(user.getId(), role));
        return authResult(user, tokens.issue(user, deviceId));
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResult signIn(String mobile, String code, String deviceId) {
        otp.verify(mobile, OtpPurpose.SIGN_IN, code);
        User user = users.findByMobile(mobile).orElseThrow(() -> new ApiException(ErrorCode.OTP_INVALID));
        if (user.getRole() == Role.ADMIN && !adminMobiles.isEmpty() && !adminMobiles.contains(mobile)) {
            throw new ApiException(ErrorCode.FORBIDDEN, "This number is not allowed to sign in as admin");
        }
        if (user.isSuspended()) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Account suspended. Contact support.");
        }
        return authResult(user, tokens.issue(user, deviceId));
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResult refresh(String refreshToken) {
        RefreshToken previous = tokens.rotate(refreshToken);
        User user = users.findById(previous.getUserId()).orElseThrow(() -> new ApiException(ErrorCode.UNAUTHENTICATED));
        // B-1201: admin sessions end after N idle minutes (no refresh within the window)
        if (user.getRole() == Role.ADMIN && previous.getCreatedAt()
                .plus(java.time.Duration.ofMinutes(settings.getInt("admin.idle_minutes"))).isBefore(Instant.now(clock))) {
            tokens.revokeFamily(previous);
            throw new ApiException(ErrorCode.TOKEN_EXPIRED, "Session ended after inactivity — sign in again");
        }
        if (user.isSuspended()) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Account suspended. Contact support.");
        }
        return authResult(user, tokens.issueInFamily(user, previous));
    }

    @Transactional
    public void signOut(String refreshToken) {
        tokens.revoke(refreshToken);
    }

    public record AuthResult(String accessToken, String refreshToken, long expiresIn, Map<String, Object> user) {
    }

    private AuthResult authResult(User user, TokenService.Issued issued) {
        return new AuthResult(issued.accessToken(), issued.refreshToken(), issued.expiresIn(), me(user));
    }

    // ---------------------------------------------------------------- me

    @Transactional(readOnly = true)
    public Map<String, Object> me(UUID userId) {
        return me(user(userId));
    }

    /** Contract {@code Me}; fields owned by other modules come from {@link MeContributor}s. */
    Map<String, Object> me(User u) {
        Map<String, Object> me = new HashMap<>();
        me.put("id", u.getId());
        me.put("name", u.getName());
        me.put("mobile", u.getMobile());
        me.put("role", u.getRole());
        me.put("language", u.getLanguage());
        me.put("photoUrl", u.getPhotoFileId() == null ? null : files.viewUrl(u.getPhotoFileId()));
        me.put("verificationStatus", u.getVerificationStatus());
        me.put("profileCompletion", u.getProfileCompletion());
        me.put("trustScore", u.getTrustScore());
        me.put("walletBalanceInr", null);
        me.put("pendingRatingsCount", 0);
        me.put("unreadNotifications", 0);
        for (MeContributor c : contributors.orderedStream().toList()) {
            me.putAll(c.contribute(u.getId(), u.getRole()));
        }
        return me;
    }

    public record AddressInput(String line, String village, String district, String state, String pin) {
    }

    @Transactional
    public Map<String, Object> updateMe(UUID userId, String name, String email, Language language, AddressInput address) {
        User u = user(userId);
        u.updateProfile(name.trim(), email == null || email.isBlank() ? null : email.trim(), language);
        if (address != null) {
            Address a = addresses.findById(userId).orElseGet(() -> new Address(userId));
            a.update(address.line(), address.village(), address.district(), address.state(), address.pin());
            addresses.save(a);
        }
        recompute(u);
        return me(u);
    }

    @Transactional(readOnly = true)
    public AddressInput address(UUID userId) {
        return addresses.findById(userId)
                .map(a -> new AddressInput(a.line(), a.village(), a.district(), a.state(), a.pin()))
                .orElse(null);
    }

    @Transactional
    public void startMobileChange(UUID userId, String newMobile) {
        User u = user(userId);
        if (users.existsByMobile(newMobile)) {
            throw new ApiException(ErrorCode.MOBILE_IN_USE);
        }
        otp.send(newMobile, OtpPurpose.CHANGE_MOBILE, userId, u.getLanguage());
    }

    @Transactional(noRollbackFor = ApiException.class)
    public Map<String, Object> verifyMobileChange(UUID userId, String newMobile, String code) {
        Otp used = otp.verify(newMobile, OtpPurpose.CHANGE_MOBILE, code);
        if (!userId.equals(used.getUserId())) {
            throw new ApiException(ErrorCode.OTP_INVALID);
        }
        if (users.existsByMobile(newMobile)) {
            throw new ApiException(ErrorCode.MOBILE_IN_USE);
        }
        User u = user(userId);
        String before = Masking.mobile(u.getMobile());
        u.setMobile(newMobile);
        audit.record(userId, "MOBILE_CHANGED", "USER", userId, before, Masking.mobile(newMobile), null);
        return me(u);
    }

    @Transactional
    public Map<String, Object> updateRoleProfile(UUID userId, Map<String, Object> body) {
        User u = user(userId);
        String data = roleProfileRules.validate(u.getRole(), body);
        RoleProfile p = roleProfiles.findById(userId).orElseGet(() -> new RoleProfile(userId, u.getRole()));
        p.update(data, Instant.now(clock));
        roleProfiles.save(p);
        recompute(u);
        return roleProfileRules.read(data);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> roleProfile(UUID userId) {
        return roleProfiles.findById(userId).map(p -> roleProfileRules.read(p.data())).orElse(Map.of());
    }

    @Transactional
    public void registerDevice(UUID userId, String fcmToken, String platform) {
        Device d = devices.findByFcmToken(fcmToken).orElseGet(() -> new Device(fcmToken));
        d.assign(userId, platform, Instant.now(clock));
        devices.save(d);
    }

    // ---------------------------------------------------------------- completion / verification

    @Transactional(readOnly = true)
    public Map<String, Object> verification(UUID userId) {
        User u = user(userId);
        List<ProfileCompletion.Item> items = ProfileCompletion.items(completionInput(u));
        Map<String, Object> view = new HashMap<>();
        view.put("status", u.getVerificationStatus());
        view.put("items", items);
        view.put("documents", documents.list(userId));
        view.put("estimatedReviewHours", settings.getInt("verification.estimated_review_hours"));
        return view;
    }

    /** Recomputes and stores {@code profileCompletion}. */
    @Transactional
    public int recompute(UUID userId) {
        return recompute(user(userId));
    }

    int recompute(User u) {
        int percent = ProfileCompletion.percent(ProfileCompletion.items(completionInput(u)));
        u.setProfileCompletion(percent);
        return percent;
    }

    private ProfileCompletion.Input completionInput(User u) {
        Set<DocumentType> docs = documents.activeTypes(u.getId());
        return new ProfileCompletion.Input(u.getRole(), u.getName() != null && !u.getName().isBlank(),
                u.getPhotoFileId() != null || docs.contains(DocumentType.PHOTO),
                addresses.existsById(u.getId()), roleProfiles.existsById(u.getId()), docs);
    }

    /** B-202: only at 100% → UNDER_REVIEW. */
    @Transactional
    public Map<String, Object> submitForVerification(UUID userId) {
        User u = user(userId);
        if (recompute(u) < 100) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Complete your profile first");
        }
        if (u.getVerificationStatus() == VerificationStatus.VERIFIED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already verified");
        }
        u.changeVerification(VerificationStatus.UNDER_REVIEW);
        return verification(userId);
    }

    User user(UUID userId) {
        return users.findById(userId).orElseThrow(() -> new ApiException(ErrorCode.UNAUTHENTICATED));
    }
}
