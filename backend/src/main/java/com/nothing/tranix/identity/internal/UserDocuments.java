package com.nothing.tranix.identity.internal;

import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import com.nothing.tranix.shared.files.FileService;
import com.nothing.tranix.shared.types.DocumentStatus;
import com.nothing.tranix.shared.types.DocumentType;

import org.springframework.stereotype.Component;

/** The user's own documents as seen by completion and verification (no dependency on DocumentService). */
@Component
class UserDocuments {

    private final DocumentRepository documents;
    private final FileService files;

    UserDocuments(DocumentRepository documents, FileService files) {
        this.documents = documents;
        this.files = files;
    }

    /** Types with a document that is PENDING or APPROVED (rejected ones don't count). */
    Set<DocumentType> activeTypes(UUID userId) {
        return own(userId).stream().filter(d -> d.getStatus() != DocumentStatus.REJECTED).map(Document::getType)
                .collect(Collectors.toCollection(() -> EnumSet.noneOf(DocumentType.class)));
    }

    List<com.nothing.tranix.identity.api.DocumentRegistry.DocumentView> list(UUID userId) {
        return own(userId).stream().map(d -> new com.nothing.tranix.identity.api.DocumentRegistry.DocumentView(
                d.getId(), d.getType(), d.getNumberMasked(), d.getExpiresOn(), d.getStatus(), d.getRejectReason(),
                d.fileIdList().isEmpty() ? null : files.viewUrl(d.fileIdList().getFirst()))).toList();
    }

    private List<Document> own(UUID userId) {
        return documents.findByOwnerTypeAndOwnerIdOrderByCreatedAt(Document.OwnerType.USER, userId);
    }
}
