package com.nothing.tranix.identity.internal;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.nothing.tranix.identity.api.RequiresVerified;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.security.CurrentUser;

import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** B-107: blocks {@link RequiresVerified} handlers for users who are not VERIFIED (or are suspended). */
@Component
class VerifiedGuard implements HandlerInterceptor {

    private final UserDirectory directory;

    VerifiedGuard(UserDirectory directory) {
        this.directory = directory;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (handler instanceof HandlerMethod hm
                && (hm.hasMethodAnnotation(RequiresVerified.class)
                || hm.getBeanType().isAnnotationPresent(RequiresVerified.class))) {
            UserDirectory.UserView user = directory.get(CurrentUser.id());
            if (!user.verified()) {
                throw new ApiException(ErrorCode.NOT_VERIFIED, "Complete verification to do this");
            }
        }
        return true;
    }
}

@Configuration(proxyBeanMethods = false)
class IdentityWebConfig implements WebMvcConfigurer {

    private final VerifiedGuard guard;

    IdentityWebConfig(VerifiedGuard guard) {
        this.guard = guard;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(guard).addPathPatterns("/api/v1/**");
    }
}

@Component
class UserDirectoryImpl implements UserDirectory {

    private final UserRepository users;
    private final DeviceRepository devices;
    private final IdentityService identity;
    private final org.springframework.jdbc.core.JdbcTemplate jdbc;

    UserDirectoryImpl(UserRepository users, DeviceRepository devices, @org.springframework.context.annotation.Lazy IdentityService identity,
                      org.springframework.jdbc.core.JdbcTemplate jdbc) {
        this.jdbc = jdbc;
        this.users = users;
        this.devices = devices;
        this.identity = identity;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<UserView> find(UUID userId) {
        return users.findById(userId).map(UserDirectoryImpl::view);
    }

    @Override
    public UserView get(UUID userId) {
        return find(userId).orElseThrow(() -> ApiException.notFound("User"));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<UserView> findByMobile(String mobile) {
        return users.findByMobile(mobile).map(UserDirectoryImpl::view);
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> fcmTokens(UUID userId) {
        return devices.findByUserId(userId).stream().map(Device::getFcmToken).toList();
    }

    @Override
    public Map<String, Object> roleProfile(UUID userId) {
        return identity.roleProfile(userId);
    }

    @Override
    @Transactional
    public void updateTrustScore(UUID userId, BigDecimal score) {
        users.findById(userId).ifPresent(u -> u.setTrustScore(score));
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrgView> searchOrganizations(String q, int limit) {
        String term = q == null ? "" : q.trim().toLowerCase(java.util.Locale.ROOT);
        String code = term.startsWith("org-") ? term.substring(4) : term;
        return jdbc.query("""
                select u.id, cast(p.data as jsonb) ->> 'orgName' org_name, a.district, u.trust_score
                from identity_user u join identity_role_profile p on p.user_id = u.id
                left join identity_address a on a.user_id = u.id
                where u.role = 'ORGANIZATION' and u.verification_status = 'VERIFIED' and u.suspended_at is null
                  and (lower(cast(p.data as jsonb) ->> 'orgName') like ? or (length(?) >= 3 and cast(u.id as text) like ?))
                order by u.trust_score desc limit ?""",
                (rs, i) -> {
                    UUID id = rs.getObject(1, UUID.class);
                    return new OrgView(id, rs.getString(2), UserDirectory.orgCode(id), rs.getString(3), rs.getBigDecimal(4));
                }, "%" + term.replace("%", "") + "%", code, code.replace("%", "") + "%", limit);
    }

    static UserView view(User u) {
        return new UserView(u.getId(), u.getName(), u.getMobile(), u.getRole(), u.getLanguage(),
                u.getVerificationStatus(), u.getTrustScore(), u.isSuspended(), u.getPhotoFileId());
    }
}
