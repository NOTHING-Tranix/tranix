package com.nothing.tranix.shared.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Swagger UI at /swagger-ui.html with an "Authorize" button for the JWT access token (B-010). */
@Configuration(proxyBeanMethods = false)
public class OpenApiConfig {

    static final String BEARER = "bearerAuth";

    @Bean
    OpenAPI tranixOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Tranix API")
                        .version("v1")
                        .description("Human-readable plan: docs/api-contract.md. Use Authorize with an access token "
                                + "from POST /api/v1/auth/sign-in (dev OTP 123456)."))
                .components(new Components().addSecuritySchemes(BEARER, new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")))
                .addSecurityItem(new SecurityRequirement().addList(BEARER));
    }
}
