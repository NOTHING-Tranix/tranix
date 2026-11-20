package com.nothing.tranix.identity.internal;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.types.OtpPurpose;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

final class IdentityRepositories {
    private IdentityRepositories() {
    }
}

interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByMobile(String mobile);

    boolean existsByMobile(String mobile);

    List<User> findByVerificationStatusAndRoleInOrderByUpdatedAt(com.nothing.tranix.shared.types.VerificationStatus status, java.util.Collection<com.nothing.tranix.shared.types.Role> roles);
}

interface AddressRepository extends JpaRepository<Address, UUID> {
}

interface RoleProfileRepository extends JpaRepository<RoleProfile, UUID> {
}

interface OtpRepository extends JpaRepository<Otp, UUID> {
    List<Otp> findByMobileAndPurposeOrderByCreatedAtDesc(String mobile, OtpPurpose purpose);

    long countByMobileAndCreatedAtAfter(String mobile, Instant after);

    @Query("select max(o.lockedUntil) from Otp o where o.mobile = ?1 and o.purpose = ?2")
    Instant lockedUntil(String mobile, OtpPurpose purpose);
}

interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByTokenHash(String hash);

    @Modifying
    @Query("update RefreshToken t set t.revokedAt = ?2 where t.familyId = ?1 and t.revokedAt is null")
    int revokeFamily(UUID familyId, Instant now);
}

interface DeviceRepository extends JpaRepository<Device, UUID> {
    Optional<Device> findByFcmToken(String token);

    List<Device> findByUserId(UUID userId);
}
