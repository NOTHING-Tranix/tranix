package com.nothing.tranix.shared.files;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

interface StoredFileRepository extends JpaRepository<StoredFile, UUID> {
}
