package com.nothing.tranix.shared.files;

import java.util.UUID;

import com.nothing.tranix.shared.security.CurrentUser;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/files")
@Tag(name = "Files")
class FilesController {

    private final FileService files;

    FilesController(FileService files) {
        this.files = files;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload a PDF/JPG/PNG (≤ 10 MB); returns fileId to use in other requests")
    FileUploaded upload(@RequestPart("file") MultipartFile file) {
        return new FileUploaded(files.upload(CurrentUser.id(), file).getId());
    }

    @GetMapping("/{id}/content")
    @Operation(summary = "View a file through a signed, short-lived URL (viewUrl)")
    @SecurityRequirements
    ResponseEntity<InputStreamResource> content(@PathVariable UUID id, @RequestParam long exp,
                                                @RequestParam String sig) {
        FileService.Content c = files.openSigned(id, exp, sig);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(c.contentType()))
                .contentLength(c.sizeBytes())
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline")
                .header("X-Content-Type-Options", "nosniff")
                .body(new InputStreamResource(c.stream()));
    }

    record FileUploaded(UUID fileId) {
    }
}
