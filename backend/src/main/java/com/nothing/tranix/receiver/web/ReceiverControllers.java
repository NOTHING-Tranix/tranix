package com.nothing.tranix.receiver.web;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.receiver.internal.ReceiverService;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.PaymentMode;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

final class ReceiverBodies {

    private ReceiverBodies() {
    }

    record Receipt(@NotNull @Size(min = 1, max = 5) List<UUID> fileIds, @NotBlank @Pattern(regexp = "FULL|SHORTAGE_DAMAGE") String condition,
                   @Size(max = 500) String remarks) {
    }

    record Rating(@Min(1) @Max(5) int stars, @Size(max = 5) List<String> tags, @Size(max = 500) String comment) {
    }

    record MarkPaid(@NotNull @Positive Long amountInr, @NotNull PaymentMode mode, @Size(max = 60) String reference) {
    }
}

/** Contract §10 public link JSON (no JWT; the token is the credential). Expired → 410 with no load data. */
@RestController
@RequestMapping("/api/v1/public/track/{token}")
class PublicTrackController {

    private final ReceiverService receivers;

    PublicTrackController(ReceiverService receivers) {
        this.receivers = receivers;
    }

    @GetMapping
    Map<String, Object> view(@PathVariable String token) {
        return receivers.publicView(token);
    }

    @PostMapping("/files")
    Map<String, Object> upload(@PathVariable String token, @RequestPart("file") MultipartFile file) {
        return receivers.uploadFromLink(token, file);
    }

    @PostMapping("/receipt")
    Map<String, Object> receipt(@PathVariable String token, @Valid @RequestBody ReceiverBodies.Receipt req) {
        return receivers.receiptFromLink(token, req.fileIds(), req.condition(), req.remarks());
    }

    @PostMapping("/rating")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void rate(@PathVariable String token, @Valid @RequestBody ReceiverBodies.Rating req) {
        receivers.rateFromLink(token, req.stars(), req.tags(), req.comment());
    }

    @PostMapping("/payment/mark-paid")
    Map<String, Object> markPaid(@PathVariable String token, @Valid @RequestBody ReceiverBodies.MarkPaid req) {
        return receivers.markPaidFromLink(token, req.amountInr(), req.mode(), req.reference());
    }
}

/** Contract §10 registered receiver (app). */
@RestController
@RequestMapping("/api/v1/receiver/loads")
class ReceiverController {

    private final ReceiverService receivers;

    ReceiverController(ReceiverService receivers) {
        this.receivers = receivers;
    }

    @GetMapping
    List<Map<String, Object>> list(@RequestParam(defaultValue = "ONGOING") @Pattern(regexp = "ONGOING|HISTORY") String scope) {
        return receivers.appLoads(CurrentUser.id(), "ONGOING".equals(scope));
    }

    @GetMapping("/{id}")
    Map<String, Object> detail(@PathVariable UUID id) {
        return receivers.appDetail(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/receipt")
    Map<String, Object> receipt(@PathVariable UUID id, @Valid @RequestBody ReceiverBodies.Receipt req) {
        return receivers.appReceipt(CurrentUser.id(), id, req.fileIds(), req.condition(), req.remarks());
    }
}

/** B-1002: the server-rendered link page; data comes from the public JSON (polled every 30 s). */
@Controller
class TrackPageController {

    private final ReceiverService receivers;

    TrackPageController(ReceiverService receivers) {
        this.receivers = receivers;
    }

    @GetMapping("/p/track/{token}")
    String page(@PathVariable String token, @RequestParam(required = false) String lang, Model model, HttpServletResponse response) {
        model.addAttribute("lang", lang == null || !List.of("en", "ta", "hi").contains(lang) ? "en" : lang);
        model.addAttribute("token", token);
        try {
            receivers.link(token);
            model.addAttribute("expired", false);
        } catch (ApiException e) {
            response.setStatus(e.code().status().value());
            model.addAttribute("expired", true);
        }
        return "receiver/track";
    }
}
