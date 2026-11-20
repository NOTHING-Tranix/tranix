package com.nothing.tranix.identity.internal;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Collection;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.UserEvents;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.files.FileService;
import com.nothing.tranix.shared.integrations.AadhaarVerifier;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.DocumentStatus;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

interface DocumentRepository extends JpaRepository<Document, UUID> {
    List<Document> findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType ownerType, UUID ownerId);

    java.util.Optional<Document> findByOwnerTypeAndOwnerIdAndType(Document.OwnerType ownerType, UUID ownerId, DocumentType type);

    List<Document> findByOwnerTypeAndStatusOrderByUpdatedAt(Document.OwnerType ownerType, DocumentStatus status);

    List<Document> findByExpiresOnIsNotNullAndExpiresOnBefore(LocalDate date);
}

/** B-201…B-206: documents, review, Aadhaar result, expiry reminders. */
@Service
public class DocumentService implements DocumentRegistry, com.nothing.tranix.identity.api.VerificationReview {

    /** India time for date-based rules (expiry). */
    static final ZoneId IST = ZoneId.of("Asia/Kolkata");

    static final Set<DocumentType> NEEDS_EXPIRY = EnumSet.of(DocumentType.DRIVING_LICENCE, DocumentType.RC,
            DocumentType.INSURANCE, DocumentType.NATIONAL_PERMIT);
    static final Set<DocumentType> NEEDS_NUMBER = EnumSet.of(DocumentType.PAN, DocumentType.VOTER_ID,
            DocumentType.DRIVING_LICENCE, DocumentType.RC, DocumentType.INSURANCE, DocumentType.NATIONAL_PERMIT,
            DocumentType.GST_CERT);
    static final Set<DocumentType> USER_COMMON = EnumSet.of(DocumentType.PAN, DocumentType.VOTER_ID,
            DocumentType.DRIVING_LICENCE, DocumentType.PHOTO);
    static final Set<DocumentType> TRUCK_TYPES = EnumSet.of(DocumentType.RC, DocumentType.INSURANCE,
            DocumentType.NATIONAL_PERMIT);

    private final DocumentRepository documents;
    private final UserRepository users;
    private final FileService files;
    private final AadhaarVerifier aadhaar;
    private final IdentityService identity;
    private final Settings settings;
    private final AuditLog audit;
    private final ApplicationEventPublisher events;
    private final JdbcTemplate jdbc;
    private final Clock clock;

    DocumentService(DocumentRepository documents, UserRepository users, FileService files, AadhaarVerifier aadhaar,
                    IdentityService identity, Settings settings, AuditLog audit, ApplicationEventPublisher events,
                    JdbcTemplate jdbc, Clock clock) {
        this.documents = documents;
        this.users = users;
        this.files = files;
        this.aadhaar = aadhaar;
        this.identity = identity;
        this.settings = settings;
        this.audit = audit;
        this.events = events;
        this.jdbc = jdbc;
        this.clock = clock;
    }

    // ------------------------------------------------------------ user documents (B-201, B-206)

    static Set<DocumentType> allowedForUser(Role role) {
        Set<DocumentType> s = EnumSet.copyOf(USER_COMMON);
        switch (role) {
            case FARMER_NETWORK -> s.addAll(List.of(DocumentType.FN_REGISTRATION_CERT, DocumentType.GST_CERT));
            case ORGANIZATION -> s.addAll(List.of(DocumentType.ORG_REGISTRATION_CERT, DocumentType.GST_CERT));
            case LOAD_PROVIDER -> s.add(DocumentType.GST_CERT);
            default -> {
            }
        }
        return s;
    }

    @Transactional
    public DocumentView submitOwn(UUID userId, DocumentType type, List<UUID> fileIds, String number, LocalDate expiresOn) {
        User u = identity.user(userId);
        if (!allowedForUser(u.getRole()).contains(type)) {
            throw ApiException.invalidField("type", "This document type is not used for your account");
        }
        DocumentView view = submit(Owner.USER, userId, userId, type, fileIds, number, expiresOn);
        if (type == DocumentType.PHOTO) {
            u.setPhotoFileId(fileIds.getFirst());
        }
        identity.recompute(u);
        // B-206: a NOT_VERIFIED user who fixes documents goes back to review once the profile is complete.
        if (u.getVerificationStatus() == VerificationStatus.NOT_VERIFIED && u.getProfileCompletion() == 100) {
            u.changeVerification(VerificationStatus.UNDER_REVIEW);
        }
        return view;
    }

    @Transactional
    public DocumentView replaceOwn(UUID userId, UUID documentId, List<UUID> fileIds, String number, LocalDate expiresOn) {
        Document d = documents.findById(documentId)
                .filter(x -> x.getOwnerType() == Document.OwnerType.USER && x.getOwnerId().equals(userId))
                .orElseThrow(() -> ApiException.notFound("Document"));
        return submitOwn(userId, d.getType(), fileIds, number, expiresOn);
    }

    @Override
    @Transactional
    public DocumentView submit(Owner owner, UUID ownerId, UUID uploadedBy, DocumentType type, List<UUID> fileIds,
                               String number, LocalDate expiresOn) {
        if (type == DocumentType.AADHAAR_OFFLINE) {
            throw ApiException.invalidField("type", "Use Aadhaar offline verification");
        }
        if (owner == Owner.TRUCK && !TRUCK_TYPES.contains(type)) {
            throw ApiException.invalidField("type", "Not a truck document");
        }
        if (fileIds == null || fileIds.isEmpty() || fileIds.size() > 3) {
            throw ApiException.invalidField("fileIds", "Attach 1 to 3 files");
        }
        files.requireOwned(uploadedBy, fileIds);
        String clean = number == null ? null : number.replaceAll("[\\s-]", "").toUpperCase();
        if (NEEDS_NUMBER.contains(type) && (clean == null || clean.length() < 4)) {
            throw ApiException.invalidField("number", "Enter the document number");
        }
        if (type == DocumentType.PAN && !clean.matches(RoleProfiles.PAN)) {
            throw ApiException.invalidField("number", "Invalid PAN");
        }
        LocalDate today = LocalDate.now(clock.withZone(IST));
        if (NEEDS_EXPIRY.contains(type) && expiresOn == null) {
            throw ApiException.invalidField("expiresOn", "Enter the expiry date");
        }
        if (expiresOn != null && !expiresOn.isAfter(today)) {
            throw ApiException.invalidField("expiresOn", "This document has already expired");
        }
        Document.OwnerType ot = Document.OwnerType.valueOf(owner.name());
        Document d = documents.findByOwnerTypeAndOwnerIdAndType(ot, ownerId, type)
                .orElseGet(() -> new Document(ot, ownerId, uploadedBy, type));
        d.submit(fileIds, mask(clean), expiresOn);
        return view(documents.save(d));
    }

    @Override
    @Transactional(readOnly = true)
    public List<DocumentView> list(Owner owner, UUID ownerId) {
        return documents.findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType.valueOf(owner.name()), ownerId)
                .stream().map(this::view).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public boolean allApprovedAndValid(Owner owner, UUID ownerId, Collection<DocumentType> types, LocalDate date) {
        Map<DocumentType, Document> byType = documents
                .findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType.valueOf(owner.name()), ownerId).stream()
                .collect(Collectors.toMap(Document::getType, d -> d, (a, b) -> b));
        return types.stream().allMatch(t -> {
            Document d = byType.get(t);
            return d != null && d.getStatus() == DocumentStatus.APPROVED
                    && (d.getExpiresOn() == null || !d.getExpiresOn().isBefore(date));
        });
    }

    Set<DocumentType> activeTypes(UUID userId) {
        return documents.findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType.USER, userId).stream()
                .filter(d -> d.getStatus() != DocumentStatus.REJECTED)
                .map(Document::getType).collect(Collectors.toCollection(() -> EnumSet.noneOf(DocumentType.class)));
    }

    DocumentView view(Document d) {
        List<UUID> ids = d.fileIdList();
        return new DocumentView(d.getId(), d.getType(), d.getNumberMasked(), d.getExpiresOn(), d.getStatus(),
                d.getRejectReason(), ids.isEmpty() ? null : files.viewUrl(ids.getFirst()));
    }

    static String mask(String number) {
        if (number == null || number.isEmpty()) {
            return null;
        }
        int keep = Math.min(4, number.length());
        return "X".repeat(number.length() - keep) + number.substring(number.length() - keep);
    }

    // ------------------------------------------------------------ Aadhaar (B-204)

    public record AadhaarResult(boolean verified, String last4, String name) {
    }

    @Transactional
    public AadhaarResult verifyAadhaarOffline(UUID userId, String qrPayload) {
        AadhaarVerifier.Result r = aadhaar.verifyOfflineQr(qrPayload);
        Instant now = Instant.now(clock);
        jdbc.update("""
                insert into identity_aadhaar_check (id, subject_type, subject_id, method, last4, name_on_record, verified, verified_at)
                values (?, 'USER', ?, 'OFFLINE_QR', ?, ?, ?, ?)""",
                UUID.randomUUID(), userId, r.last4(), r.nameOnRecord(), r.verified(), java.sql.Timestamp.from(now));
        if (r.verified()) {
            Document d = documents.findByOwnerTypeAndOwnerIdAndType(Document.OwnerType.USER, userId, DocumentType.AADHAAR_OFFLINE)
                    .orElseGet(() -> new Document(Document.OwnerType.USER, userId, userId, DocumentType.AADHAAR_OFFLINE));
            d.submit(List.of(), "XXXXXXXX" + r.last4(), null);
            d.approveAutomatically(now);
            documents.save(d);
            identity.recompute(userId);
        }
        return new AadhaarResult(r.verified(), r.last4(), r.nameOnRecord());
    }

    // ------------------------------------------------------------ admin review (B-203)


    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> queue(Tab tab) {
        if (tab == Tab.VEHICLE) {
            return documents.findByOwnerTypeAndStatusOrderByUpdatedAt(Document.OwnerType.TRUCK, DocumentStatus.PENDING)
                    .stream().collect(Collectors.groupingBy(Document::getOwnerId, java.util.LinkedHashMap::new, Collectors.toList()))
                    .entrySet().stream()
                    .map(e -> Map.<String, Object>of("ownerType", "TRUCK", "ownerId", e.getKey(),
                            "documents", e.getValue().stream().map(this::view).toList()))
                    .toList();
        }
        Set<Role> roles = switch (tab) {
            case DRIVER -> Set.of(Role.DRIVER);
            case FARMER_NETWORK -> Set.of(Role.FARMER_NETWORK);
            case ORGANIZATION -> Set.of(Role.ORGANIZATION);
            default -> Set.of(Role.LOAD_PROVIDER, Role.RECEIVER);
        };
        return users.findByVerificationStatusAndRoleInOrderByUpdatedAt(VerificationStatus.UNDER_REVIEW, roles).stream()
                .map(u -> Map.<String, Object>of("userId", u.getId(), "name", u.getName(), "role", u.getRole(),
                        "mobile", u.getMobile(), "submittedAt", u.getUpdatedAt(),
                        "roleProfile", identity.roleProfile(u.getId()),
                        "documents", list(Owner.USER, u.getId())))
                .toList();
    }

    @Override
    @Transactional
    public DocumentView review(UUID adminId, UUID documentId, boolean approve, String reason) {
        if (!approve && (reason == null || reason.isBlank())) {
            throw ApiException.invalidField("reason", "Give a reason");
        }
        Document d = documents.findById(documentId).orElseThrow(() -> ApiException.notFound("Document"));
        if (d.getStatus() != DocumentStatus.PENDING) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Document already reviewed");
        }
        d.review(approve, reason, adminId, Instant.now(clock));
        audit.record(adminId, approve ? "DOCUMENT_APPROVED" : "DOCUMENT_REJECTED", "DOCUMENT", d.getId(),
                "PENDING", d.getStatus().name(), reason);
        if (!approve) {
            events.publishEvent(new UserEvents.DocumentRejected(d.getUserId(), d.getId(), d.getType().name(), reason));
        }
        if (d.getOwnerType() == Document.OwnerType.USER) {
            decideUser(adminId, d.getOwnerId());
        }
        return view(d);
    }

    /** When all of a user's documents are reviewed: any rejected → NOT_VERIFIED, else VERIFIED. */
    private void decideUser(UUID adminId, UUID userId) {
        User u = identity.user(userId);
        if (u.getVerificationStatus() != VerificationStatus.UNDER_REVIEW) {
            return;
        }
        List<Document> docs = documents.findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType.USER, userId);
        if (docs.stream().anyMatch(x -> x.getStatus() == DocumentStatus.PENDING)) {
            return;
        }
        List<Document> rejected = docs.stream().filter(x -> x.getStatus() == DocumentStatus.REJECTED).toList();
        VerificationStatus next = rejected.isEmpty() ? VerificationStatus.VERIFIED : VerificationStatus.NOT_VERIFIED;
        u.changeVerification(next);
        String reason = rejected.stream().map(x -> x.getType() + ": " + x.getRejectReason()).collect(Collectors.joining("; "));
        audit.record(adminId, "VERIFICATION_" + next, "USER", userId, "UNDER_REVIEW", next.name(), reason);
        events.publishEvent(new UserEvents.VerificationChanged(userId, next, reason.isEmpty() ? null : reason));
    }

    // ------------------------------------------------------------ expiry job (B-205)

    @Scheduled(cron = "${tranix.jobs.document-expiry-cron:0 30 1 * * *}", zone = "Asia/Kolkata")
    @Transactional
    public void expiryJob() {
        LocalDate today = LocalDate.now(clock.withZone(IST));
        List<Integer> days = settings.getIntList(SettingKeys.DOCUMENT_EXPIRY_REMINDER_DAYS);
        int max = days.stream().mapToInt(Integer::intValue).max().orElse(30);
        for (Document d : documents.findByExpiresOnIsNotNullAndExpiresOnBefore(today.plusDays(max + 1L))) {
            if (d.getStatus() == DocumentStatus.REJECTED) {
                continue;
            }
            long left = ChronoUnit.DAYS.between(today, d.getExpiresOn());
            if (left < 0) {
                if (!d.isExpiredNotified()) {
                    d.markExpiredNotified();
                    events.publishEvent(new UserEvents.DocumentExpired(d.getUserId(), d.getId(), d.getType().name(),
                            d.getOwnerType().name(), d.getOwnerId()));
                }
                continue;
            }
            days.stream().filter(n -> left <= n && !d.reminderSent(n)).min(Integer::compare).ifPresent(n -> {
                // mark this and all larger thresholds so a late run sends one reminder, not several
                days.stream().filter(x -> x >= n).forEach(d::markReminder);
                events.publishEvent(new UserEvents.DocumentExpiring(d.getUserId(), d.getId(), d.getType().name(), (int) left));
            });
        }
    }
}
