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

    static {
        add("ORG_INVITE", true, true,
                "Organization invitation", "{org} invited you to drive for them. Open Tranix to accept or reject.",
                "நிறுவன அழைப்பு", "{org} உங்களை ஓட்டுநராக அழைத்துள்ளது. ஏற்க அல்லது நிராகரிக்க டிரானிக்ஸைத் திறக்கவும்.",
                "संगठन का निमंत्रण", "{org} ने आपको ड्राइवर के रूप में बुलाया है। स्वीकार या अस्वीकार करने के लिए ट्रानिक्स खोलें।");
        add("INVITE_ACCEPTED", true, false,
                "Invitation accepted", "{driver} joined your Organization.",
                "அழைப்பு ஏற்கப்பட்டது", "{driver} உங்கள் நிறுவனத்தில் சேர்ந்தார்.",
                "निमंत्रण स्वीकार", "{driver} आपके संगठन से जुड़ गए।");
        add("INVITE_REJECTED", true, false,
                "Invitation rejected", "{driver} rejected your invitation.",
                "அழைப்பு நிராகரிக்கப்பட்டது", "{driver} உங்கள் அழைப்பை நிராகரித்தார்.",
                "निमंत्रण अस्वीकार", "{driver} ने आपका निमंत्रण अस्वीकार किया।");
    }

    static {
        add("NEW_SUGGESTION", true, false,
                "New trip suggestion", "{pickup} → {drop} · ₹{amount}",
                "புதிய பயணப் பரிந்துரை", "{pickup} → {drop} · ₹{amount}",
                "नया यात्रा सुझाव", "{pickup} → {drop} · ₹{amount}");
        add("PREFERRED_SUGGESTION", true, false,
                "A shipper who prefers you posted a load", "{pickup} → {drop} · ₹{amount}",
                "உங்களை விரும்பும் அனுப்புநர் சரக்கைப் பதிவு செய்தார்", "{pickup} → {drop} · ₹{amount}",
                "आपको पसंद करने वाले शिपर ने लोड पोस्ट किया", "{pickup} → {drop} · ₹{amount}");
        add("LOAD_ACCEPTED", true, false,
                "Load accepted", "{code}: {driver} ({truck}) accepted your load.",
                "சரக்கு ஏற்கப்பட்டது", "{code}: {driver} ({truck}) உங்கள் சரக்கை ஏற்றுக்கொண்டார்.",
                "लोड स्वीकार", "{code}: {driver} ({truck}) ने आपका लोड स्वीकार किया।");
        add("NO_DRIVER_FOUND", true, false,
                "No driver yet", "{code}: no driver has accepted yet. You can raise the amount, change the pickup time, wait or cancel free.",
                "இன்னும் ஓட்டுநர் இல்லை", "{code}: இன்னும் யாரும் ஏற்கவில்லை. தொகையை உயர்த்தலாம், நேரத்தை மாற்றலாம், காத்திருக்கலாம் அல்லது இலவசமாக ரத்து செய்யலாம்.",
                "अभी कोई ड्राइवर नहीं", "{code}: अभी किसी ने स्वीकार नहीं किया। राशि बढ़ाएँ, समय बदलें, इंतज़ार करें या मुफ़्त रद्द करें।");
    }

    static {
        add("AMOUNT_REQUEST", true, false,
                "Amount request", "{code}: driver asks ₹{amount} — {reason}. Answer within {minutes} min; no answer keeps the current amount.",
                "தொகை கோரிக்கை", "{code}: ஓட்டுநர் ₹{amount} கேட்கிறார் — {reason}. {minutes} நிமிடத்தில் பதிலளிக்கவும்.",
                "राशि अनुरोध", "{code}: ड्राइवर ₹{amount} माँग रहा है — {reason}। {minutes} मिनट में जवाब दें।");
        add("AMOUNT_CONFIRMED", true, false, "Amount confirmed", "{code}: new amount ₹{amount}.",
                "தொகை உறுதி", "{code}: புதிய தொகை ₹{amount}.", "राशि पक्की", "{code}: नई राशि ₹{amount}।");
        add("AMOUNT_REJECTED", true, false, "Amount not changed", "{code}: the amount stays ₹{amount}. The trip continues.",
                "தொகை மாறவில்லை", "{code}: தொகை ₹{amount} ஆகவே இருக்கும். பயணம் தொடரும்.",
                "राशि नहीं बदली", "{code}: राशि ₹{amount} ही रहेगी। यात्रा जारी है।");
        add("AMOUNT_EXPIRED", true, false, "No answer", "{code}: no answer in time — the amount stays ₹{amount}.",
                "பதில் இல்லை", "{code}: நேரத்தில் பதில் இல்லை — தொகை ₹{amount}.",
                "जवाब नहीं मिला", "{code}: समय पर जवाब नहीं — राशि ₹{amount} ही रहेगी।");
        add("DRIVER_REACHED_PICKUP", true, false, "Driver reached pickup", "{code}: open the trip to see the pickup OTP and share it after loading.",
                "ஓட்டுநர் வந்துவிட்டார்", "{code}: ஏற்றும் OTP-ஐப் பார்க்க பயணத்தைத் திறக்கவும்.",
                "ड्राइवर पिकअप पर पहुँचा", "{code}: पिकअप OTP देखने के लिए यात्रा खोलें।");
        add("DRIVER_REACHED_DROP", true, false, "Driver arrived", "{code}: check the goods, then share the delivery OTP.",
                "ஓட்டுநர் வந்துவிட்டார்", "{code}: சரக்கைச் சரிபார்த்து, பின் OTP-ஐப் பகிரவும்.",
                "ड्राइवर पहुँच गया", "{code}: माल जाँचें, फिर डिलीवरी OTP बताएँ।");
        add("PICKED_UP", true, false, "Picked up", "{code}: goods picked up and on the way.",
                "ஏற்றப்பட்டது", "{code}: சரக்கு ஏற்றப்பட்டு வருகிறது.", "माल उठाया गया", "{code}: माल उठाया गया और रास्ते में है।");
        add("DELIVERED", true, false, "Delivered", "{code}: delivered. Please confirm payment and rate the trip.",
                "ஒப்படைக்கப்பட்டது", "{code}: ஒப்படைக்கப்பட்டது. கட்டணத்தை உறுதிசெய்து மதிப்பிடவும்.",
                "डिलीवर हुआ", "{code}: डिलीवर हुआ। भुगतान और रेटिंग पूरी करें।");
        add("RUNNING_LATE", true, false, "Running late", "{code}: the truck is running late.",
                "தாமதம்", "{code}: லாரி தாமதமாக வருகிறது.", "देरी", "{code}: ट्रक देरी से चल रहा है।");
        add("CANCELLED_BY_DRIVER", true, false, "Trip cancelled by driver", "{code}: the driver cancelled. You can post the load again.",
                "ஓட்டுநர் ரத்து செய்தார்", "{code}: ஓட்டுநர் ரத்து செய்தார். மீண்டும் பதிவு செய்யலாம்.",
                "ड्राइवर ने रद्द किया", "{code}: ड्राइवर ने रद्द किया। आप फिर से पोस्ट कर सकते हैं।");
        add("CANCELLED_BY_SHIPPER", true, false, "Trip cancelled", "{code}: the shipper cancelled this trip.",
                "பயணம் ரத்து", "{code}: அனுப்புநர் இந்தப் பயணத்தை ரத்து செய்தார்.", "यात्रा रद्द", "{code}: शिपर ने यह यात्रा रद्द की।");
    }

    static {
        add("PAYMENT_MARKED", true, false, "Payment marked paid", "{code}: ₹{amount} by {mode}. Confirm when you receive it.",
                "கட்டணம் செலுத்தப்பட்டது", "{code}: ₹{amount} ({mode}). பெற்றதும் உறுதிசெய்யவும்.",
                "भुगतान दर्ज", "{code}: ₹{amount} ({mode})। मिलने पर पुष्टि करें।");
        add("PAYMENT_CONFIRMED", true, false, "Payment confirmed", "{code}: the driver confirmed the payment.",
                "கட்டணம் உறுதி", "{code}: ஓட்டுநர் கட்டணத்தை உறுதிசெய்தார்.", "भुगतान की पुष्टि", "{code}: ड्राइवर ने भुगतान की पुष्टि की।");
        add("PAYMENT_DISPUTED", true, false, "Payment disputed", "{code}: the driver raised a payment dispute. Tranix support will contact you.",
                "கட்டண சர்ச்சை", "{code}: ஓட்டுநர் கட்டண சர்ச்சை எழுப்பினார். உதவி மையம் தொடர்பு கொள்ளும்.",
                "भुगतान विवाद", "{code}: ड्राइवर ने भुगतान विवाद उठाया। सहायता टीम संपर्क करेगी।");
        add("RATING_REMINDER", true, false, "Rate your trip", "{code}: please rate your trip partner.",
                "பயணத்தை மதிப்பிடவும்", "{code}: உங்கள் பயணக் கூட்டாளியை மதிப்பிடவும்.", "यात्रा रेट करें", "{code}: अपने यात्रा साथी को रेट करें।");
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
