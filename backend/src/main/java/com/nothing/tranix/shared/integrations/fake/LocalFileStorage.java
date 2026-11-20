package com.nothing.tranix.shared.integrations.fake;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.util.regex.Pattern;

import com.nothing.tranix.shared.integrations.FileStorage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Stores files under {@code tranix.files.storage-dir} with random names. Never served directly. */
@Component
@ConditionalOnProperty(name = "tranix.integrations.files", havingValue = "local", matchIfMissing = true)
public class LocalFileStorage implements FileStorage {

    private static final Pattern KEY = Pattern.compile("[0-9a-f-]{36}");

    private final Path root;

    public LocalFileStorage(@Value("${tranix.files.storage-dir:./data/files}") String dir) throws IOException {
        this.root = Path.of(dir).toAbsolutePath().normalize();
        Files.createDirectories(root);
    }

    @Override
    public String store(InputStream content, String contentType) throws IOException {
        String key = UUID.randomUUID().toString();
        Files.copy(content, resolve(key), StandardCopyOption.REPLACE_EXISTING);
        return key;
    }

    @Override
    public InputStream open(String key) throws IOException {
        return Files.newInputStream(resolve(key));
    }

    @Override
    public void delete(String key) throws IOException {
        Files.deleteIfExists(resolve(key));
    }

    private Path resolve(String key) {
        if (key == null || !KEY.matcher(key).matches()) {
            throw new IllegalArgumentException("Bad storage key");
        }
        return root.resolve(key);
    }
}
