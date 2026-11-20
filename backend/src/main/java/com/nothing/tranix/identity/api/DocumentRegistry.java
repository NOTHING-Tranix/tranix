package com.nothing.tranix.identity.api;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import com.nothing.tranix.shared.types.DocumentStatus;
import com.nothing.tranix.shared.types.DocumentType;

/** Documents of trucks and farmers (owned by other modules) are stored here too. */
public interface DocumentRegistry {

    enum Owner { USER, TRUCK, FARMER }

    /** Creates or replaces the owner's document of this type; status becomes PENDING. */
    DocumentView submit(Owner owner, UUID ownerId, UUID uploadedBy, DocumentType type, List<UUID> fileIds,
                        String number, LocalDate expiresOn);

    List<DocumentView> list(Owner owner, UUID ownerId);

    /** True when every type has an APPROVED document that is not expired on {@code date}. */
    boolean allApprovedAndValid(Owner owner, UUID ownerId, Collection<DocumentType> types, LocalDate date);

    record DocumentView(UUID id, DocumentType type, String numberMasked, LocalDate expiresOn, DocumentStatus status,
                        String rejectReason, String viewUrl) {
    }
}
