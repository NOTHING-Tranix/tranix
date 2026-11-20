package com.nothing.tranix.shared.settings;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;

import com.nothing.tranix.IntegrationTest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class PublicSettingsIT {

    @Autowired
    MockMvc mvc;

    @Autowired
    Settings settings;

    @Test
    void publicSettingsMatchContractWithoutToken() throws Exception {
        mvc.perform(get("/api/v1/settings/public"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.postingChargeInr").value(50))
                .andExpect(jsonPath("$.tripChargeInr").value(50))
                .andExpect(jsonPath("$.topupChips").value(contains(500, 1000, 2000)))
                .andExpect(jsonPath("$.otpTtlSeconds").value(300))
                .andExpect(jsonPath("$.otpResendSeconds").value(30))
                .andExpect(jsonPath("$.revisionLimit").value(5))
                .andExpect(jsonPath("$.revisionResponseMinutes").value(15))
                .andExpect(jsonPath("$.geofenceMeters").value(500))
                .andExpect(jsonPath("$.wishlistMax").value(20))
                .andExpect(jsonPath("$.wishlistFirstMinutes").value(15))
                .andExpect(jsonPath("$.wishlistOnlyNotifyMinutes").value(30))
                .andExpect(jsonPath("$.goodsTypes").isNotEmpty())
                .andExpect(jsonPath("$.vehicleTypes").value(hasItem("REFRIGERATED")))
                .andExpect(jsonPath("$.ticketTypes").value(hasItem("PAYMENT_DISPUTE")))
                .andExpect(jsonPath("$.rejectReasons").value(contains("TOO_FAR", "LOW_AMOUNT", "WRONG_TRUCK", "OTHER")))
                .andExpect(jsonPath("$.supportedLanguages").value(contains("en", "ta", "hi")));
    }

    @Test
    void typedGetters() {
        assertThat(settings.getInt(SettingKeys.TRUST_START_SCORE)).isEqualTo(70);
        assertThat(settings.getDecimal("trust.points.rating_4")).isEqualByComparingTo(new BigDecimal("0.5"));
        assertThat(settings.getDecimal("matching.weight.distance")).isEqualByComparingTo("30");
        assertThat(settings.getIntList(SettingKeys.DOCUMENT_EXPIRY_REMINDER_DAYS)).containsExactly(30, 7, 1);
        assertThatThrownBy(() -> settings.getInt("no.such.key")).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> settings.getInt(SettingKeys.GOODS_TYPES)).isInstanceOf(IllegalStateException.class);
    }
}
