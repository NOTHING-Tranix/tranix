-- B-008: uploaded files (documents, receipts, ticket photos). Bytes live in FileStorage, never in public storage.
CREATE TABLE shared_file (
    id            UUID         PRIMARY KEY,
    owner_user_id UUID         NOT NULL,
    storage_key   VARCHAR(100) NOT NULL UNIQUE,
    content_type  VARCHAR(50)  NOT NULL,
    size_bytes    BIGINT       NOT NULL CHECK (size_bytes > 0),
    created_at    TIMESTAMPTZ  NOT NULL,
    updated_at    TIMESTAMPTZ  NOT NULL,
    version       BIGINT       NOT NULL
);

CREATE INDEX shared_file_owner_idx ON shared_file (owner_user_id);
