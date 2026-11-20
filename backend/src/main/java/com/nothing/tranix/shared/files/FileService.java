package com.nothing.tranix.shared.files;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collection;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.integrations.FileStorage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

/**
 * Upload (PDF/JPG/PNG, size limit from settings, type checked by magic bytes) and signed, short-lived view URLs.
 * Other modules use {@link #requireOwned} when a request references {@code fileIds} and {@link #viewUrl} when
 * returning a document.
 */
@Service
public class FileService {

    static final String PDF = "application/pdf";
    static final String JPEG = "image/jpeg";
    static final String PNG = "image/png";

    private final StoredFileRepository repository;
    private final FileStorage storage;
    private final Settings settings;
    private final Clock clock;
    private final byte[] signingKey;
    private final Duration viewUrlTtl;
    private final String publicBaseUrl;

    FileService(StoredFileRepository repository, FileStorage storage, Settings settings, Clock clock,
                @Value("${tranix.files.signing-secret}") String signingSecret,
                @Value("${tranix.files.view-url-ttl:5m}") Duration viewUrlTtl,
                @Value("${tranix.public-base-url:http://localhost:8080}") String publicBaseUrl) {
        if (signingSecret == null || signingSecret.length() < 32) {
            throw new IllegalStateException("tranix.files.signing-secret must be at least 32 characters");
        }
        this.repository = repository;
        this.storage = storage;
        this.settings = settings;
        this.clock = clock;
        this.signingKey = signingSecret.getBytes(StandardCharsets.UTF_8);
        this.viewUrlTtl = viewUrlTtl;
        this.publicBaseUrl = publicBaseUrl.endsWith("/")
                ? publicBaseUrl.substring(0, publicBaseUrl.length() - 1) : publicBaseUrl;
    }

    @Transactional
    public StoredFile upload(UUID ownerUserId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw ApiException.invalidField("file", "Choose a file");
        }
        long maxBytes = settings.getInt(SettingKeys.FILES_MAX_MB) * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            throw ApiException.invalidField("file", "File is larger than " + settings.getInt(SettingKeys.FILES_MAX_MB) + " MB");
        }
        byte[] bytes;
        try {
            bytes = file.getBytes();
        } catch (IOException e) {
            throw ApiException.invalidField("file", "Could not read the file");
        }
        String type = detectType(bytes);
        if (type == null) {
            throw ApiException.invalidField("file", "Only PDF, JPG or PNG files are allowed");
        }
        String key;
        try {
            key = storage.store(new ByteArrayInputStream(bytes), type);
        } catch (IOException e) {
            throw new IllegalStateException("Could not store file", e);
        }
        return repository.save(new StoredFile(ownerUserId, key, type, bytes.length));
    }

    /** Every id must exist and belong to {@code ownerUserId}; otherwise VALIDATION_FAILED on {@code fileIds}. */
    @Transactional(readOnly = true)
    public void requireOwned(UUID ownerUserId, Collection<UUID> fileIds) {
        for (UUID id : fileIds) {
            boolean ok = repository.findById(id).map(f -> f.getOwnerUserId().equals(ownerUserId)).orElse(false);
            if (!ok) {
                throw ApiException.invalidField("fileIds", "Unknown file");
            }
        }
    }

    /** Absolute URL valid for {@code tranix.files.view-url-ttl} (5 min). */
    public String viewUrl(UUID fileId) {
        long exp = Instant.now(clock).plus(viewUrlTtl).getEpochSecond();
        return publicBaseUrl + "/api/v1/files/" + fileId + "/content?exp=" + exp + "&sig=" + sign(fileId, exp);
    }

    @Transactional(readOnly = true)
    public Content openSigned(UUID fileId, long exp, String sig) {
        if (sig == null || Instant.now(clock).getEpochSecond() > exp
                || !MessageDigest.isEqual(sign(fileId, exp).getBytes(StandardCharsets.UTF_8),
                sig.getBytes(StandardCharsets.UTF_8))) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Link expired or invalid");
        }
        StoredFile file = repository.findById(fileId).orElseThrow(() -> ApiException.notFound("File"));
        try {
            return new Content(file.getContentType(), file.getSizeBytes(), storage.open(file.getStorageKey()));
        } catch (IOException e) {
            throw ApiException.notFound("File");
        }
    }

    String sign(UUID fileId, long exp) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(signingKey, "HmacSHA256"));
            byte[] h = mac.doFinal((fileId + ":" + exp).getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(h);
        } catch (Exception e) {
            throw new IllegalStateException("HMAC failed", e);
        }
    }

    static String detectType(byte[] b) {
        if (startsWith(b, new byte[] {'%', 'P', 'D', 'F'})) {
            return PDF;
        }
        if (startsWith(b, new byte[] {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A})) {
            return PNG;
        }
        if (startsWith(b, new byte[] {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF})) {
            return JPEG;
        }
        return null;
    }

    private static boolean startsWith(byte[] data, byte[] prefix) {
        return data.length >= prefix.length && Arrays.equals(data, 0, prefix.length, prefix, 0, prefix.length);
    }

    public record Content(String contentType, long sizeBytes, InputStream stream) {
    }
}
