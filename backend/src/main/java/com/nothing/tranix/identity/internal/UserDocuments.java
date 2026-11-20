package com.nothing.tranix.identity.internal;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.shared.types.DocumentType;

import org.springframework.stereotype.Component;

/** The user's own documents as seen by completion and verification. Filled in by B-201. */
@Component
class UserDocuments {

    /** Types with a document that is PENDING or APPROVED (rejected ones don't count). */
    Set<DocumentType> activeTypes(UUID userId) {
        return Set.of();
    }

    List<Map<String, Object>> list(UUID userId) {
        return List.of();
    }
}
