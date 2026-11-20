package com.nothing.tranix.shared.security;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.nothing.tranix.shared.error.ErrorCode;

import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.server.resource.InvalidBearerTokenException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import tools.jackson.databind.json.JsonMapper;

/**
 * Writes 401/403 as contract problems: {@code TOKEN_EXPIRED} when the access token is expired (the app then
 * refreshes), {@code UNAUTHENTICATED} otherwise, {@code FORBIDDEN} for a wrong role.
 */
@Component
public class ProblemAuthenticationHandlers implements AuthenticationEntryPoint, AccessDeniedHandler {

    private final JsonMapper json;

    public ProblemAuthenticationHandlers(JsonMapper json) {
        this.json = json;
    }

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException ex)
            throws IOException {
        boolean expired = ex instanceof InvalidBearerTokenException
                && ex.getMessage() != null && ex.getMessage().toLowerCase().contains("expired");
        ErrorCode code = expired ? ErrorCode.TOKEN_EXPIRED : ErrorCode.UNAUTHENTICATED;
        write(response, code, expired ? "Access token expired" : "Sign in required");
    }

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException ex)
            throws IOException {
        write(response, ErrorCode.FORBIDDEN, "You can't do this");
    }

    private void write(HttpServletResponse response, ErrorCode code, String detail) throws IOException {
        response.setStatus(code.status().value());
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> body = Map.of(
                "type", "about:blank",
                "title", code.title(),
                "status", code.status().value(),
                "code", code.name(),
                "detail", detail,
                "fields", List.of());
        json.writeValue(response.getOutputStream(), body);
    }
}
