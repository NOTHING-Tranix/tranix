package com.nothing.tranix.shared.integrations;

import java.io.IOException;
import java.io.InputStream;

/** Private object storage for uploads (local disk now, S3 later). Keys are opaque. */
public interface FileStorage {

    /** Stores the bytes and returns a storage key. */
    String store(InputStream content, String contentType) throws IOException;

    InputStream open(String key) throws IOException;

    void delete(String key) throws IOException;
}
