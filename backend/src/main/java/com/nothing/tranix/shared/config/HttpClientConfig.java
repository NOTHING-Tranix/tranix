package com.nothing.tranix.shared.config;

import java.time.Duration;

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * HTTP client for the outside-service connectors (Twilio, MSG91, Razorpay, FCM, OSRM, Nominatim, Google).
 * Spring Boot 4 no longer auto-configures a {@link RestClient.Builder} without the separate restclient starter,
 * so one is defined here: a new builder per injection point, with sensible timeouts.
 */
@Configuration(proxyBeanMethods = false)
class HttpClientConfig {

    @Bean
    @Scope("prototype")
    @ConditionalOnMissingBean
    RestClient.Builder restClientBuilder() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(5));
        factory.setReadTimeout(Duration.ofSeconds(15));
        return RestClient.builder().requestFactory(factory);
    }
}
