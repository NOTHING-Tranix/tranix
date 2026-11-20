package com.nothing.tranix.shared.files;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import com.nothing.tranix.shared.domain.BaseEntity;

@Entity
@Table(name = "shared_file")
public class StoredFile extends BaseEntity {

    @Column(name = "owner_user_id", nullable = false, updatable = false)
    private UUID ownerUserId;

    @Column(name = "storage_key", nullable = false, updatable = false, length = 100)
    private String storageKey;

    @Column(name = "content_type", nullable = false, updatable = false, length = 50)
    private String contentType;

    @Column(name = "size_bytes", nullable = false, updatable = false)
    private long sizeBytes;

    protected StoredFile() {
    }

    StoredFile(UUID ownerUserId, String storageKey, String contentType, long sizeBytes) {
        this.ownerUserId = ownerUserId;
        this.storageKey = storageKey;
        this.contentType = contentType;
        this.sizeBytes = sizeBytes;
    }

    public UUID getOwnerUserId() {
        return ownerUserId;
    }

    public String getStorageKey() {
        return storageKey;
    }

    public String getContentType() {
        return contentType;
    }

    public long getSizeBytes() {
        return sizeBytes;
    }
}
