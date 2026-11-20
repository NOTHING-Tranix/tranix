package com.nothing.tranix.shared.integrations;

/** Payment gateway for wallet top-ups (real provider: Q-02, Razorpay preferred). */
public interface PaymentGateway {

    /** Creates a gateway order for a top-up; {@code receipt} is our own order id. */
    GatewayOrder createOrder(String receipt, long amountInr);

    /**
     * Verifies a webhook's signature and parses it. Returns {@code null} when the signature is wrong; the caller
     * must then reject the webhook and never credit the wallet.
     */
    WebhookEvent verifyWebhook(String rawBody, String signature);

    record GatewayOrder(String gatewayOrderId, String checkoutUrl) {
    }

    /** {@code eventId} makes webhook handling idempotent. */
    record WebhookEvent(String eventId, String gatewayOrderId, boolean paid, long amountInr) {
    }
}
