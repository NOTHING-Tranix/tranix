package com.nothing.tranix;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

/** B-004: module boundaries (CLAUDE.md §5) — no cycles, modules use each other only via their api. */
class ModularityTests {

    static final ApplicationModules MODULES = ApplicationModules.of(TranixApplication.class);

    @Test
    void verifiesModuleStructure() {
        MODULES.verify();
    }

    @Test
    void hasAllModulesFromClaudeMd() {
        assertThat(MODULES.stream().map(m -> m.getIdentifier().toString()))
                .contains("shared", "identity", "fleet", "farmers", "loads", "matching", "trips", "wallet",
                        "payments", "trust", "engagement", "admin", "web");
    }
}
