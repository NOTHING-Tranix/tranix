package com.nothing.tranix.wallet.web;

import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.shared.integrations.fake.FakePaymentGateway;
import com.nothing.tranix.wallet.internal.TopupService;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;

/** B-303: server-rendered top-up page (Thymeleaf) opened from the app in the external browser. */
@Controller
class TopupPageController {

    static final Map<String, Map<String, String>> TEXT = Map.of(
            "en", Map.of("title", "Add money to your Tranix wallet", "amount", "Amount", "pay", "Pay now",
                    "expired", "This link has expired. Go back to the app and try again.",
                    "invalid", "This link is not valid.", "paid", "Payment received. Your wallet is updated — go back to the app.",
                    "for", "For"),
            "ta", Map.of("title", "உங்கள் டிரானிக்ஸ் வாலட்டில் பணம் சேர்க்கவும்", "amount", "தொகை", "pay", "இப்போது செலுத்து",
                    "expired", "இந்த இணைப்பு காலாவதியானது. ஆப்பிற்குத் திரும்பி மீண்டும் முயற்சிக்கவும்.",
                    "invalid", "இந்த இணைப்பு செல்லாது.", "paid", "பணம் பெறப்பட்டது. வாலட் புதுப்பிக்கப்பட்டது — ஆப்பிற்குத் திரும்பவும்.",
                    "for", "யாருக்கு"),
            "hi", Map.of("title", "अपने ट्रानिक्स वॉलेट में पैसे जोड़ें", "amount", "राशि", "pay", "अभी भुगतान करें",
                    "expired", "यह लिंक समाप्त हो गया है। ऐप पर वापस जाकर फिर से कोशिश करें।",
                    "invalid", "यह लिंक मान्य नहीं है।", "paid", "भुगतान मिल गया। वॉलेट अपडेट हो गया — ऐप पर वापस जाएँ।",
                    "for", "किसके लिए"));

    private final TopupService topups;

    TopupPageController(TopupService topups) {
        this.topups = topups;
    }

    @GetMapping("/p/wallet/topup")
    String page(@RequestParam(name = "t", required = false) String token, Model model) {
        TopupService.PageModel p = topups.page(token);
        model.addAttribute("p", p);
        model.addAttribute("t", TEXT.getOrDefault(p.language(), TEXT.get("en")));
        return "wallet/topup";
    }
}

/** Dev only: the fake gateway's "checkout" — pressing Pay posts a correctly signed webhook. */
@Controller
@Profile("dev")
class DevPaymentController {

    private final TopupService topups;
    private final ObjectProvider<FakePaymentGateway> fake;

    DevPaymentController(TopupService topups, ObjectProvider<FakePaymentGateway> fake) {
        this.topups = topups;
        this.fake = fake;
    }

    @GetMapping("/dev/payments/{gatewayOrderId}")
    String checkout(@PathVariable String gatewayOrderId, Model model) {
        model.addAttribute("orderId", gatewayOrderId);
        model.addAttribute("amount", topups.amountForGatewayOrder(gatewayOrderId));
        return "wallet/dev-checkout";
    }

    @PostMapping("/dev/payments/{gatewayOrderId}/succeed")
    String succeed(@PathVariable String gatewayOrderId, Model model) {
        FakePaymentGateway gw = fake.getIfAvailable();
        Long amount = topups.amountForGatewayOrder(gatewayOrderId);
        if (gw == null || amount == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        String body = "evt_" + UUID.randomUUID() + "|" + gatewayOrderId + "|PAID|" + amount;
        model.addAttribute("result", topups.handleWebhook(body, gw.sign(body)).name());
        model.addAttribute("t", TopupPageController.TEXT.get("en"));
        return "wallet/dev-done";
    }
}
