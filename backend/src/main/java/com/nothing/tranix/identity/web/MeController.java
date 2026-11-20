package com.nothing.tranix.identity.web;

import java.util.Map;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.identity.internal.IdentityService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.Language;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §4 (profile part). */
@RestController
@RequestMapping("/api/v1/me")
@Tag(name = "Me")
class MeController {

    private final IdentityService identity;

    MeController(IdentityService identity) {
        this.identity = identity;
    }

    record AddressBody(@NotBlank @Size(max = 200) String line, @NotBlank @Size(max = 100) String village,
                       @NotBlank @Size(max = 100) String district, @NotBlank @Size(max = 100) String state,
                       @NotBlank @Pattern(regexp = "^[1-9][0-9]{5}$", message = "Enter a 6-digit PIN") String pin) {
    }

    record UpdateMe(@NotBlank @Size(min = 2, max = 60) String name, @Email @Size(max = 120) String email,
                    @NotNull Language language, @Valid AddressBody address) {
    }

    record MobileChange(@NotBlank @Pattern(regexp = AuthController.MOBILE, message = "Enter a valid 10-digit mobile") String mobile) {
    }

    record MobileVerify(@NotBlank @Pattern(regexp = AuthController.MOBILE, message = "Enter a valid 10-digit mobile") String mobile,
                        @NotBlank @Pattern(regexp = AuthController.OTP, message = "Enter the 6-digit OTP") String otp) {
    }

    record DeviceBody(@NotBlank @Size(max = 400) String fcmToken,
                      @NotBlank @Pattern(regexp = "ANDROID|WEB", message = "ANDROID or WEB") String platform) {
    }

    @GetMapping
    Map<String, Object> me() {
        return identity.me(CurrentUser.id());
    }

    @PutMapping
    Map<String, Object> update(@Valid @RequestBody UpdateMe req) {
        AddressBody a = req.address();
        return identity.updateMe(CurrentUser.id(), req.name(), req.email(), req.language(),
                a == null ? null : new IdentityService.AddressInput(a.line(), a.village(), a.district(), a.state(), a.pin()));
    }

    @GetMapping("/address")
    IdentityService.AddressInput address() {
        return identity.address(CurrentUser.id());
    }

    @PostMapping("/mobile/change")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void changeMobile(@Valid @RequestBody MobileChange req) {
        identity.startMobileChange(CurrentUser.id(), req.mobile());
    }

    @PostMapping("/mobile/verify")
    Map<String, Object> verifyMobile(@Valid @RequestBody MobileVerify req) {
        return identity.verifyMobileChange(CurrentUser.id(), req.mobile(), req.otp());
    }

    @GetMapping("/role-profile")
    Map<String, Object> roleProfile() {
        return identity.roleProfile(CurrentUser.id());
    }

    @PutMapping("/role-profile")
    Map<String, Object> updateRoleProfile(@RequestBody Map<String, Object> body) {
        return identity.updateRoleProfile(CurrentUser.id(), body);
    }

    @GetMapping("/verification")
    Map<String, Object> verification() {
        return identity.verification(CurrentUser.id());
    }

    @PostMapping("/verification/submit")
    Map<String, Object> submit() {
        return identity.submitForVerification(CurrentUser.id());
    }

    @PostMapping("/devices")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void device(@Valid @RequestBody DeviceBody req) {
        identity.registerDevice(CurrentUser.id(), req.fcmToken(), req.platform());
    }
}
