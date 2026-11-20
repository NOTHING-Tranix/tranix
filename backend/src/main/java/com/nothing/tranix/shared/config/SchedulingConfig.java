package com.nothing.tranix.shared.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Server-side timers (hard rule 10). Off in tests ({@code tranix.jobs.enabled=false}); tests call jobs directly. */
@Configuration(proxyBeanMethods = false)
@EnableScheduling
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
public class SchedulingConfig {
}
