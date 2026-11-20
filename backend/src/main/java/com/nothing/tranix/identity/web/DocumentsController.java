package com.nothing.tranix.identity.web;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.internal.DocumentService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.DocumentType;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** B-201, B-204, B-206 (contract §4). */
@RestController
@RequestMapping("/api/v1/me")
@Tag(name = "Me")
class DocumentsController {

    private final DocumentService documents;

    DocumentsController(DocumentService documents) {
        this.documents = documents;
    }

    record NewDocument(@NotNull DocumentType type, @NotEmpty @Size(max = 3) List<UUID> fileIds,
                       @Size(max = 30) String number, LocalDate expiresOn) {
    }

    record Replacement(@NotEmpty @Size(max = 3) List<UUID> fileIds, @Size(max = 30) String number, LocalDate expiresOn) {
    }

    record AadhaarOffline(@NotBlank @Size(max = 20000) String qrPayload) {
    }

    @GetMapping("/documents")
    List<DocumentRegistry.DocumentView> list() {
        return documents.list(DocumentRegistry.Owner.USER, CurrentUser.id());
    }

    @PostMapping("/documents")
    DocumentRegistry.DocumentView create(@Valid @RequestBody NewDocument req) {
        return documents.submitOwn(CurrentUser.id(), req.type(), req.fileIds(), req.number(), req.expiresOn());
    }

    @PutMapping("/documents/{id}")
    DocumentRegistry.DocumentView replace(@PathVariable UUID id, @Valid @RequestBody Replacement req) {
        return documents.replaceOwn(CurrentUser.id(), id, req.fileIds(), req.number(), req.expiresOn());
    }

    @PostMapping("/aadhaar/offline")
    DocumentService.AadhaarResult aadhaar(@Valid @RequestBody AadhaarOffline req) {
        return documents.verifyAadhaarOffline(CurrentUser.id(), req.qrPayload());
    }
}
