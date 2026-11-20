package com.nothing.tranix.identity.internal;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.types.Role;

import org.springframework.stereotype.Component;

import tools.jackson.databind.json.JsonMapper;

/** B-110: role-specific profile fields (contract §4.1) with format checks. */
@Component
class RoleProfiles {

    static final String PAN = "^[A-Z]{5}[0-9]{4}[A-Z]$";
    static final String GSTIN = "^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$";
    static final String CIN = "^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$";
    /** Indian driving licence: state code + RTO + year + serial, e.g. TN5720190012345 (spaces/dashes removed). */
    static final String LICENCE = "^[A-Z]{2}[0-9]{2}[0-9]{4}[0-9]{7}$";
    static final String MOBILE = "^[6-9][0-9]{9}$";

    private final JsonMapper json;
    private final Validator validator;

    RoleProfiles(JsonMapper json, Validator validator) {
        this.json = json;
        this.validator = validator;
    }

    record LoadProvider(@NotNull AccountType accountType, @Size(max = 120) String businessName,
                        @Pattern(regexp = GSTIN, message = "Invalid GSTIN") String gstin) {
        enum AccountType { INDIVIDUAL, BUSINESS }

        @AssertTrue(message = "Business name is required")
        boolean isBusinessNameGiven() {
            return accountType != AccountType.BUSINESS || (businessName != null && !businessName.isBlank());
        }
    }

    record FarmerNetwork(@NotBlank @Size(max = 120) String networkName, @NotBlank String registrationNumber,
                         @NotNull IdType idType, @NotBlank String idNumber, @NotBlank String contactPerson,
                         @NotBlank String state, @NotBlank String district) {
        enum IdType { CIN, PAN, GSTIN }

        @AssertTrue(message = "ID number does not match the ID type")
        boolean isIdNumberValid() {
            if (idType == null || idNumber == null) {
                return true;
            }
            return idNumber.matches(switch (idType) {
                case CIN -> CIN;
                case PAN -> PAN;
                case GSTIN -> GSTIN;
            });
        }
    }

    record Driver(@NotBlank @Pattern(regexp = LICENCE, message = "Invalid licence number") String licenceNumber,
                  @NotNull @Future LocalDate licenceValidUntil, @NotEmpty List<@NotBlank String> vehicleClasses,
                  @Pattern(regexp = MOBILE, message = "Invalid mobile") String emergencyContact) {
    }

    record Organization(@NotBlank @Size(max = 120) String orgName, @NotBlank String contactPerson,
                        @Pattern(regexp = GSTIN, message = "Invalid GSTIN") String gstin,
                        @Pattern(regexp = PAN, message = "Invalid PAN") String pan) {
    }

    record Receiver(@Size(max = 120) String businessName) {
    }

    /** Validates {@code body} for the role and returns normalised JSON to store. */
    String validate(Role role, Map<String, Object> body) {
        Object profile = parse(role, normalise(role, body));
        Set<ConstraintViolation<Object>> violations = validator.validate(profile);
        if (!violations.isEmpty()) {
            List<ApiException.FieldError> fields = violations.stream()
                    .map(v -> new ApiException.FieldError(field(v.getPropertyPath().toString()), v.getMessage()))
                    .toList();
            throw new ApiException(ErrorCode.VALIDATION_FAILED, "Some fields are invalid", fields);
        }
        return json.writeValueAsString(profile);
    }

    Map<String, Object> read(String data) {
        if (data == null) {
            return Map.of();
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> map = json.readValue(data, Map.class);
        return map;
    }

    private Object parse(Role role, Map<String, Object> body) {
        Class<?> type = switch (role) {
            case LOAD_PROVIDER -> LoadProvider.class;
            case FARMER_NETWORK -> FarmerNetwork.class;
            case DRIVER -> Driver.class;
            case ORGANIZATION -> Organization.class;
            case RECEIVER -> Receiver.class;
            case ADMIN -> throw new ApiException(ErrorCode.FORBIDDEN);
        };
        try {
            return json.convertValue(body, type);
        } catch (RuntimeException e) {
            throw new ApiException(ErrorCode.VALIDATION_FAILED, "Some fields have the wrong format");
        }
    }

    private static Map<String, Object> normalise(Role role, Map<String, Object> body) {
        Map<String, Object> copy = new java.util.HashMap<>(body);
        for (String key : List.of("gstin", "pan", "idNumber", "licenceNumber")) {
            if (copy.get(key) instanceof String s) {
                String v = s.replaceAll("[\\s-]", "").toUpperCase();
                copy.put(key, v.isEmpty() ? null : v);
            }
        }
        return copy;
    }

    private static String field(String path) {
        if (path.equals("businessNameGiven")) {
            return "businessName";
        }
        if (path.equals("idNumberValid")) {
            return "idNumber";
        }
        return path;
    }
}
