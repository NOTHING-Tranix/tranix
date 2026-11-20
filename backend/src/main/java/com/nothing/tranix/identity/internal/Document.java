package com.nothing.tranix.identity.internal;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

import com.nothing.tranix.shared.domain.BaseEntity;
import com.nothing.tranix.shared.types.DocumentStatus;
import com.nothing.tranix.shared.types.DocumentType;

@Entity
@Table(name = "identity_document")
public class Document extends BaseEntity {

    public enum OwnerType { USER, TRUCK, FARMER }

    @Enumerated(EnumType.STRING)
    @Column(name = "owner_type", nullable = false, updatable = false)
    private OwnerType ownerType;

    @Column(name = "owner_id", nullable = false, updatable = false)
    private UUID ownerId;

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, updatable = false)
    private DocumentType type;

    @Column(name = "number_masked")
    private String numberMasked;

    @Column(name = "file_ids", nullable = false)
    private String fileIds;

    @Column(name = "expires_on")
    private LocalDate expiresOn;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private DocumentStatus status = DocumentStatus.PENDING;

    @Column(name = "reject_reason")
    private String rejectReason;

    @Column(name = "reviewed_by")
    private UUID reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "reminders_sent", nullable = false)
    private String remindersSent = "";

    @Column(name = "expired_notified", nullable = false)
    private boolean expiredNotified;

    protected Document() {
    }

    Document(OwnerType ownerType, UUID ownerId, UUID userId, DocumentType type) {
        this.ownerType = ownerType;
        this.ownerId = ownerId;
        this.userId = userId;
        this.type = type;
    }

    /** New or replaced upload: back to PENDING, reminders reset. */
    void submit(List<UUID> files, String numberMasked, LocalDate expiresOn) {
        this.fileIds = files.stream().map(UUID::toString).collect(Collectors.joining(","));
        this.numberMasked = numberMasked;
        this.expiresOn = expiresOn;
        this.status = DocumentStatus.PENDING;
        this.rejectReason = null;
        this.reviewedBy = null;
        this.reviewedAt = null;
        this.remindersSent = "";
        this.expiredNotified = false;
    }

    void approveAutomatically(Instant now) {
        this.status = DocumentStatus.APPROVED;
        this.reviewedAt = now;
    }

    void review(boolean approve, String reason, UUID adminId, Instant now) {
        this.status = approve ? DocumentStatus.APPROVED : DocumentStatus.REJECTED;
        this.rejectReason = approve ? null : reason;
        this.reviewedBy = adminId;
        this.reviewedAt = now;
    }

    boolean reminderSent(int days) {
        return Arrays.asList(remindersSent.split(",")).contains(String.valueOf(days));
    }

    void markReminder(int days) {
        remindersSent = remindersSent.isEmpty() ? String.valueOf(days) : remindersSent + "," + days;
    }

    public OwnerType getOwnerType() { return ownerType; }
    public UUID getOwnerId() { return ownerId; }
    public UUID getUserId() { return userId; }
    public DocumentType getType() { return type; }
    public String getNumberMasked() { return numberMasked; }
    public LocalDate getExpiresOn() { return expiresOn; }
    public DocumentStatus getStatus() { return status; }
    public String getRejectReason() { return rejectReason; }
    boolean isExpiredNotified() { return expiredNotified; }
    void markExpiredNotified() { expiredNotified = true; }

    public List<UUID> fileIdList() {
        return fileIds == null || fileIds.isBlank() ? List.of()
                : Arrays.stream(fileIds.split(",")).map(UUID::fromString).toList();
    }
}
