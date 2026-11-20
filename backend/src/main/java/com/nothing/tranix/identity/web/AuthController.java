package com.nothing.tranix.identity.web;

import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.identity.internal.IdentityService;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.OtpPurpose;
import com.nothing.tranix.shared.types.Role;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §3. */
@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Auth")
@SecurityRequirements
class AuthController {

    static final String MOBILE = "^[6-9][0-9]{9}$";
    static final String OTP = "^[0-9]{6}$";

    private final IdentityService identity;

    AuthController(IdentityService identity) {
        this.identity = identity;
    }

    record SendOtp(@NotBlank @Pattern(regexp = MOBILE, message = "Enter a valid 10-digit mobile") String mobile,
                   @NotNull OtpPurpose purpose) {
    }

    record SignUp(@NotBlank @Pattern(regexp = MOBILE, message = "Enter a valid 10-digit mobile") String mobile,
                  @NotBlank @Pattern(regexp = OTP, message = "Enter the 6-digit OTP") String otp,
                  @NotBlank @Size(min = 2, max = 60) String name, @NotNull Role role,
                  @NotNull @AssertTrue(message = "Consent is required") Boolean consent,
                  Language language, String deviceId) {
    }

    record SignIn(@NotBlank @Pattern(regexp = MOBILE, message = "Enter a valid 10-digit mobile") String mobile,
                  @NotBlank @Pattern(regexp = OTP, message = "Enter the 6-digit OTP") String otp,
                  @Size(max = 64) String deviceId) {
    }

    record Refresh(@NotBlank String refreshToken) {
    }

    @PostMapping("/otp/send")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Send an OTP (SIGN_UP or SIGN_IN). Always 204 for SIGN_IN. Dev OTP: 123456")
    void sendOtp(@Valid @RequestBody SendOtp req) {
        identity.sendOtp(req.mobile(), req.purpose());
    }

    @PostMapping("/sign-up")
    IdentityService.AuthResult signUp(@Valid @RequestBody SignUp req) {
        return identity.signUp(req.mobile(), req.otp(), req.name(), req.role(),
                req.language() == null ? Language.en : req.language(), req.deviceId());
    }

    @PostMapping("/sign-in")
    IdentityService.AuthResult signIn(@Valid @RequestBody SignIn req) {
        return identity.signIn(req.mobile(), req.otp(), req.deviceId());
    }

    @PostMapping("/refresh")
    IdentityService.AuthResult refresh(@Valid @RequestBody Refresh req) {
        return identity.refresh(req.refreshToken());
    }

    @PostMapping("/sign-out")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void signOut(@Valid @RequestBody Refresh req) {
        identity.signOut(req.refreshToken());
    }
}
