package com.nothing.tranix;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import tools.jackson.databind.json.JsonMapper;

/** Test helper: signs users up through the real API and calls endpoints with their token. */
@Component
public class TestApi {

    private static final AtomicLong MOBILES = new AtomicLong(9_100_000_000L + (System.nanoTime() % 100_000) * 1000);

    private final MockMvc mvc;
    private final FakeSmsSender sms;
    private final JsonMapper json;
    private final JdbcTemplate jdbc;
    private final com.nothing.tranix.wallet.internal.WalletService wallet;

    public TestApi(MockMvc mvc, FakeSmsSender sms, JsonMapper json, JdbcTemplate jdbc,
                   com.nothing.tranix.wallet.internal.WalletService wallet) {
        this.wallet = wallet;
        this.mvc = mvc;
        this.sms = sms;
        this.json = json;
        this.jdbc = jdbc;
    }

    public record Session(UUID userId, String mobile, String accessToken, String refreshToken) {
    }

    public static String newMobile() {
        return String.valueOf(MOBILES.incrementAndGet());
    }

    public String lastOtp(String mobile) {
        return sms.sent().reversed().stream().filter(s -> s.mobile().equals(mobile)).findFirst()
                .map(s -> s.params().get("otp")).orElseThrow();
    }

    public Session signUp(String role) throws Exception {
        String mobile = newMobile();
        send("/api/v1/auth/otp/send", Map.of("mobile", mobile, "purpose", "SIGN_UP"), null).andExpect(status().isNoContent());
        String body = send("/api/v1/auth/sign-up", Map.of("mobile", mobile, "otp", lastOtp(mobile), "name", "Test " + role,
                "role", role, "consent", true, "language", "en", "deviceId", "dev-1"), null)
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        return new Session(UUID.fromString(JsonPath.read(body, "$.user.id")), mobile,
                JsonPath.read(body, "$.accessToken"), JsonPath.read(body, "$.refreshToken"));
    }

    /** Signs up and marks the account VERIFIED directly in the database (for business-flow tests). */
    public Session verified(String role) throws Exception {
        Session s = signUp(role);
        jdbc.update("update identity_user set verification_status = 'VERIFIED', profile_completion = 100 where id = ?",
                s.userId());
        return s;
    }

    /** A user whose role is ADMIN (role changed in the DB, then signed in again for a token with role ADMIN). */
    public Session admin() throws Exception {
        Session s = verified("RECEIVER");
        jdbc.update("update identity_user set role = 'ADMIN' where id = ?", s.userId());
        send("/api/v1/auth/otp/send", Map.of("mobile", s.mobile(), "purpose", "SIGN_IN"), null);
        String body = body(send("/api/v1/auth/sign-in", Map.of("mobile", s.mobile(), "otp", lastOtp(s.mobile())), null));
        return new Session(s.userId(), s.mobile(), JsonPath.read(body, "$.accessToken"), JsonPath.read(body, "$.refreshToken"));
    }

    /** Uploads a tiny PNG as {@code as} and returns its fileId. */
    public String uploadPng(Session as) throws Exception {
        byte[] png = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 13};
        String body = mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart("/api/v1/files")
                .file(new org.springframework.mock.web.MockMultipartFile("file", "a.png", "image/png", png))
                .header("Authorization", "Bearer " + as.accessToken())).andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.fileId");
    }

    /** Credits the wallet directly (test setup). */
    public void fund(Session s, long amountInr) {
        wallet.adminCredit(s.userId(), amountInr, "test funding", null);
    }

    public ResultActions send(String path, Object body, Session as) throws Exception {
        return mvc.perform(auth(post(path), as).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)));
    }

    public ResultActions put(String path, Object body, Session as) throws Exception {
        return mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put(path), as)
                .contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)));
    }

    public ResultActions get(String path, Session as) throws Exception {
        return mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get(path), as));
    }

    public ResultActions delete(String path, Session as) throws Exception {
        return mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete(path), as));
    }

    public String body(ResultActions r) throws Exception {
        return r.andReturn().getResponse().getContentAsString();
    }

    private static MockHttpServletRequestBuilder auth(MockHttpServletRequestBuilder b, Session as) {
        return as == null ? b : b.header("Authorization", "Bearer " + as.accessToken());
    }

}
