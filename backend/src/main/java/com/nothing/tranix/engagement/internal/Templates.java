package com.nothing.tranix.engagement.internal;

import java.util.HashMap;
import java.util.Map;

import com.nothing.tranix.shared.types.Language;

/**
 * Notification texts in en/ta/hi with {@code {param}} placeholders. Add new types here; unknown types fall back
 * to a generic text so a missing template never blocks an event.
 */
final class Templates {

    record Text(String title, String body) {
    }

    record Template(boolean push, boolean sms, Map<Language, Text> texts) {
    }

    private static final Map<String, Template> ALL = new HashMap<>();

    private static void add(String type, boolean push, boolean sms, String enT, String enB, String taT, String taB,
                            String hiT, String hiB) {
        ALL.put(type, new Template(push, sms, Map.of(Language.en, new Text(enT, enB), Language.ta, new Text(taT, taB),
                Language.hi, new Text(hiT, hiB))));
    }

    static {
        add("TOPUP_SUCCESS", true, false,
                "Wallet topped up", "₹{amount} added. Balance ₹{balance}.",
                "வாலட் டாப் அப் ஆனது", "₹{amount} சேர்க்கப்பட்டது. இருப்பு ₹{balance}.",
                "वॉलेट टॉप अप हुआ", "₹{amount} जोड़े गए। बैलेंस ₹{balance}.");
        add("CHARGE_DEDUCTED", false, false,
                "Charge deducted", "₹{amount} {charge} for trip {load}. Balance ₹{balance}.",
                "கட்டணம் கழிக்கப்பட்டது", "பயணம் {load}-க்கு ₹{amount} {charge}. இருப்பு ₹{balance}.",
                "शुल्क काटा गया", "यात्रा {load} के लिए ₹{amount} {charge}. बैलेंस ₹{balance}.");
        add("REFUND", true, false,
                "Refund received", "₹{amount} refunded to your wallet. Balance ₹{balance}.",
                "பணம் திருப்பி அளிக்கப்பட்டது", "₹{amount} உங்கள் வாலட்டில் திருப்பி அளிக்கப்பட்டது. இருப்பு ₹{balance}.",
                "रिफ़ंड मिला", "₹{amount} आपके वॉलेट में वापस आए। बैलेंस ₹{balance}.");
        add("ADMIN_CREDIT", true, false,
                "Credit from Tranix", "₹{amount} added by Tranix. Balance ₹{balance}.",
                "டிரானிக்ஸிடமிருந்து வரவு", "டிரானிக்ஸ் ₹{amount} சேர்த்தது. இருப்பு ₹{balance}.",
                "ट्रानिक्स से क्रेडिट", "ट्रानिक्स ने ₹{amount} जोड़े। बैलेंस ₹{balance}.");
        add("LOW_BALANCE", true, false,
                "Low wallet balance", "Balance ₹{balance}. Top up at least ₹{needed} to keep using Tranix.",
                "வாலட் இருப்பு குறைவு", "இருப்பு ₹{balance}. தொடர்ந்து பயன்படுத்த குறைந்தது ₹{needed} டாப் அப் செய்யவும்.",
                "वॉलेट बैलेंस कम", "बैलेंस ₹{balance}. इस्तेमाल जारी रखने के लिए कम से कम ₹{needed} टॉप अप करें।");
        add("VERIFICATION_VERIFIED", true, false,
                "You are verified", "Your account is verified. You can now use all features.",
                "நீங்கள் சரிபார்க்கப்பட்டீர்கள்", "உங்கள் கணக்கு சரிபார்க்கப்பட்டது. இப்போது அனைத்து வசதிகளையும் பயன்படுத்தலாம்.",
                "आप सत्यापित हैं", "आपका खाता सत्यापित हो गया। अब आप सभी सुविधाएँ इस्तेमाल कर सकते हैं।");
        add("VERIFICATION_NOT_VERIFIED", true, false,
                "Verification not complete", "Some documents need attention: {reason}",
                "சரிபார்ப்பு முடியவில்லை", "சில ஆவணங்களைச் சரிசெய்ய வேண்டும்: {reason}",
                "सत्यापन पूरा नहीं हुआ", "कुछ दस्तावेज़ ठीक करने होंगे: {reason}");
        add("DOCUMENT_REJECTED", true, false,
                "Document rejected", "{document}: {reason}. Please upload again.",
                "ஆவணம் நிராகரிக்கப்பட்டது", "{document}: {reason}. மீண்டும் பதிவேற்றவும்.",
                "दस्तावेज़ अस्वीकृत", "{document}: {reason}. कृपया फिर से अपलोड करें।");
        add("DOCUMENT_EXPIRING", true, false,
                "Document expiring", "{document} expires in {days} day(s). Upload the new one.",
                "ஆவணம் காலாவதியாகிறது", "{document} {days} நாளில் காலாவதியாகும். புதியதைப் பதிவேற்றவும்.",
                "दस्तावेज़ की अवधि खत्म हो रही है", "{document} {days} दिन में समाप्त होगा। नया अपलोड करें।");
        add("DOCUMENT_EXPIRED", true, false,
                "Document expired", "{document} has expired. Trips are paused until a new one is verified.",
                "ஆவணம் காலாவதியானது", "{document} காலாவதியானது. புதியது சரிபார்க்கப்படும் வரை பயணங்கள் நிறுத்தப்படும்.",
                "दस्तावेज़ समाप्त", "{document} समाप्त हो गया। नया सत्यापित होने तक यात्राएँ रुकी रहेंगी।");
    }

    private Templates() {
    }

    /** Registers templates owned by other features (loads, trips…). */
    static void register(String type, boolean push, boolean sms, String enT, String enB, String taT, String taB,
                         String hiT, String hiB) {
        add(type, push, sms, enT, enB, taT, taB, hiT, hiB);
    }

    static Template get(String type) {
        Template t = ALL.get(type);
        return t != null ? t : new Template(true, false, Map.of(Language.en, new Text("Tranix", type)));
    }

    static Text render(String type, Language lang, Map<String, String> params) {
        Template t = get(type);
        Text raw = t.texts().getOrDefault(lang, t.texts().get(Language.en));
        return new Text(fill(raw.title(), params), fill(raw.body(), params));
    }

    static String fill(String text, Map<String, String> params) {
        String out = text;
        for (Map.Entry<String, String> e : params.entrySet()) {
            out = out.replace("{" + e.getKey() + "}", e.getValue() == null ? "" : e.getValue());
        }
        return out;
    }
}
