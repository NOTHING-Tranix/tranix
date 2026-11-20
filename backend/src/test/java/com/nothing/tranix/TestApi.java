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

    public TestApi(MockMvc mvc, FakeSmsSender sms, JsonMapper json, JdbcTemplate jdbc) {
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
