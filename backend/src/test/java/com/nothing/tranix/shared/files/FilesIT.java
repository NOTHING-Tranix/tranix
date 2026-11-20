package com.nothing.tranix.shared.files;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.net.URI;
import java.util.List;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.shared.error.ApiException;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class FilesIT {

    static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 13};
    static final byte[] PDF = "%PDF-1.7\n%test".getBytes();

    @Autowired
    MockMvc mvc;

    @Autowired
    FileService files;

    final UUID user = UUID.randomUUID();

    @Test
    void uploadNeedsToken() throws Exception {
        mvc.perform(multipart("/api/v1/files").file(new MockMultipartFile("file", "a.png", "image/png", PNG)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    @Test
    void uploadPngThenViewThroughSignedUrl() throws Exception {
        String body = mvc.perform(multipart("/api/v1/files")
                        .file(new MockMultipartFile("file", "photo.png", "image/png", PNG))
                        .with(jwt().jwt(j -> j.subject(user.toString()).claim("role", "DRIVER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fileId").isString())
                .andReturn().getResponse().getContentAsString();
        UUID fileId = UUID.fromString(JsonPath.read(body, "$.fileId"));

        URI url = URI.create(files.viewUrl(fileId));
        mvc.perform(get(url.getPath() + "?" + url.getQuery()))
                .andExpect(status().isOk())
                .andExpect(content().contentType("image/png"))
                .andExpect(content().bytes(PNG));

        mvc.perform(get(url.getPath() + "?" + url.getQuery().replaceAll("sig=.*", "sig=forged")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));

        files.requireOwned(user, List.of(fileId));
        org.assertj.core.api.Assertions.assertThatThrownBy(() -> files.requireOwned(UUID.randomUUID(), List.of(fileId)))
                .isInstanceOf(ApiException.class);
    }

    @Test
    void pdfIsAccepted() throws Exception {
        mvc.perform(multipart("/api/v1/files")
                        .file(new MockMultipartFile("file", "rc.pdf", "application/pdf", PDF))
                        .with(jwt().jwt(j -> j.subject(user.toString()).claim("role", "DRIVER"))))
                .andExpect(status().isOk());
    }

    @Test
    void otherTypesAreRejectedByContentNotName() throws Exception {
        mvc.perform(multipart("/api/v1/files")
                        .file(new MockMultipartFile("file", "fake.png", "image/png", "<html>".getBytes()))
                        .with(jwt().jwt(j -> j.subject(user.toString()).claim("role", "DRIVER"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.fields[0].field").value("file"));
    }

    @Test
    void expiredLinkIsRejected() throws Exception {
        UUID id = UUID.randomUUID();
        long past = 1_000L;
        mvc.perform(get("/api/v1/files/" + id + "/content").param("exp", String.valueOf(past))
                        .param("sig", files.sign(id, past)))
                .andExpect(status().isForbidden());
    }

    @Test
    void detectsTypes() {
        assertThat(FileService.detectType(PNG)).isEqualTo("image/png");
        assertThat(FileService.detectType(PDF)).isEqualTo("application/pdf");
        assertThat(FileService.detectType(new byte[] {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 1})).isEqualTo("image/jpeg");
        assertThat(FileService.detectType("GIF89a".getBytes())).isNull();
    }
}
