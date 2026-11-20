package com.nothing.tranix.shared.settings;

import java.util.Arrays;
import java.util.List;

import com.nothing.tranix.shared.types.SuggestionRejectReason;
import com.nothing.tranix.shared.types.TicketType;
import com.nothing.tranix.shared.types.VehicleType;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/settings")
@Tag(name = "Settings")
class PublicSettingsController {

    private final Settings settings;
    private final com.nothing.tranix.shared.integrations.AadhaarVerifier aadhaar;

    PublicSettingsController(Settings settings, com.nothing.tranix.shared.integrations.AadhaarVerifier aadhaar) {
        this.aadhaar = aadhaar;
        this.settings = settings;
    }

    @GetMapping("/public")
    @Operation(summary = "Values and lists the app needs (charges, timers, dropdowns)")
    @SecurityRequirements
    PublicSettings publicSettings() {
        return new PublicSettings(
                settings.getInt(SettingKeys.POSTING_CHARGE_INR),
                settings.getInt(SettingKeys.TRIP_CHARGE_INR),
                settings.getIntList(SettingKeys.TOPUP_CHIPS_INR),
                settings.getInt(SettingKeys.OTP_TTL_SECONDS),
                settings.getInt(SettingKeys.OTP_RESEND_SECONDS),
                settings.getInt(SettingKeys.REVISION_LIMIT),
                settings.getInt(SettingKeys.REVISION_RESPONSE_MINUTES),
                settings.getInt(SettingKeys.GEOFENCE_METERS),
                settings.getInt(SettingKeys.WISHLIST_MAX_ENTRIES),
                settings.getInt(SettingKeys.WISHLIST_FIRST_MINUTES),
                settings.getInt(SettingKeys.WISHLIST_ONLY_NOTIFY_MINUTES),
                settings.getStringList(SettingKeys.GOODS_TYPES),
                names(VehicleType.values()),
                names(TicketType.values()),
                names(SuggestionRejectReason.values()),
                settings.getStringList(SettingKeys.SUPPORTED_LANGUAGES),
                aadhaar.enabled());
    }

    private static List<String> names(Enum<?>[] values) {
        return Arrays.stream(values).map(Enum::name).toList();
    }
}
