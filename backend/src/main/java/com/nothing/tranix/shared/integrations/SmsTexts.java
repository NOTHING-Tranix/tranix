package com.nothing.tranix.shared.integrations;

import java.util.Map;

import com.nothing.tranix.shared.types.Language;

/**
 * Full SMS wording per template key and language, for providers that send text (Twilio). In India the text must
 * match the DLT-approved template exactly, so change it here and on DLT together. {@code {name}} = parameter.
 * Keys sent today: OTP_SIGN_UP, OTP_SIGN_IN, OTP_CHANGE_MOBILE, TRIP_OTP_PICKUP, TRIP_OTP_DELIVERY,
 * RECEIVER_TRACKING, SENDER_TRACKING, ORG_INVITE and NOTIFY_* (notification body passed as {text}).
 */
public final class SmsTexts {

    private SmsTexts() {
    }

    private static final String OTP_EN = "{otp} is your Tranix verification code. It is valid for 5 minutes. Do not share it with anyone.";
    private static final String OTP_TA = "{otp} உங்கள் டிரானிக்ஸ் சரிபார்ப்பு குறியீடு. 5 நிமிடங்களுக்கு செல்லும். யாரிடமும் பகிர வேண்டாம்.";
    private static final String OTP_HI = "{otp} आपका ट्रानिक्स सत्यापन कोड है। 5 मिनट तक मान्य। किसी से साझा न करें।";

    static final Map<String, Map<Language, String>> TEXTS = Map.of(
            "OTP", Map.of(Language.en, OTP_EN, Language.ta, OTP_TA, Language.hi, OTP_HI),
            "TRIP_OTP_PICKUP", Map.of(
                    Language.en, "Tranix {code}: pickup OTP {otp}. Give it to the driver only after the goods are loaded.",
                    Language.ta, "டிரானிக்ஸ் {code}: ஏற்றும் OTP {otp}. பொருள் ஏற்றிய பின் மட்டும் ஓட்டுநரிடம் சொல்லவும்.",
                    Language.hi, "ट्रानिक्स {code}: पिकअप OTP {otp}। सामान लोड होने के बाद ही ड्राइवर को बताएँ।"),
            "TRIP_OTP_DELIVERY", Map.of(
                    Language.en, "Tranix {code}: delivery OTP {otp}. Give it to the driver only after checking the goods.",
                    Language.ta, "டிரானிக்ஸ் {code}: ஒப்படைப்பு OTP {otp}. பொருளைச் சரிபார்த்த பின் மட்டும் ஓட்டுநரிடம் சொல்லவும்.",
                    Language.hi, "ट्रानिक्स {code}: डिलीवरी OTP {otp}। सामान जाँचने के बाद ही ड्राइवर को बताएँ।"),
            "RECEIVER_TRACKING", Map.of(
                    Language.en, "Tranix {code}: goods from {shipper} on truck {truck} are on the way to you. Track: {link}",
                    Language.ta, "டிரானிக்ஸ் {code}: {shipper} அனுப்பிய பொருள் லாரி {truck}-ல் உங்களிடம் வருகிறது. கண்காணிக்க: {link}",
                    Language.hi, "ट्रानिक्स {code}: {shipper} का सामान ट्रक {truck} से आपके पास आ रहा है। ट्रैक करें: {link}"),
            "SENDER_TRACKING", Map.of(
                    Language.en, "Tranix {code}: {network} booked truck {truck} for your goods. Track: {link}",
                    Language.ta, "டிரானிக்ஸ் {code}: உங்கள் பொருளுக்கு {network} லாரி {truck}-ஐ பதிவு செய்தது. கண்காணிக்க: {link}",
                    Language.hi, "ट्रानिक्स {code}: {network} ने आपके सामान के लिए ट्रक {truck} बुक किया। ट्रैक करें: {link}"),
            "ORG_INVITE", Map.of(
                    Language.en, "{org} invited you to drive with them on Tranix. Install the Tranix app and sign in with this number to accept.",
                    Language.ta, "{org} டிரானிக்ஸில் தங்களுடன் ஓட்ட உங்களை அழைத்துள்ளது. டிரானிக்ஸ் ஆப்பை நிறுவி இந்த எண்ணில் உள்நுழைந்து ஏற்கவும்.",
                    Language.hi, "{org} ने आपको ट्रानिक्स पर उनके साथ ड्राइव करने का न्योता दिया है। ट्रानिक्स ऐप इंस्टॉल करें और इसी नंबर से साइन इन करें।"),
            "NOTIFY", Map.of(Language.en, "Tranix: {text}", Language.ta, "டிரானிக்ஸ்: {text}", Language.hi, "ट्रानिक्स: {text}"));

    /** The filled-in text, or null when the key has no wording (the caller then skips the SMS). */
    public static String render(String templateKey, Language language, Map<String, String> params) {
        String family = templateKey.startsWith("OTP_") ? "OTP" : templateKey.startsWith("NOTIFY_") ? "NOTIFY" : templateKey;
        Map<Language, String> byLang = TEXTS.get(family);
        if (byLang == null) {
            return null;
        }
        String text = byLang.getOrDefault(language == null ? Language.en : language, byLang.get(Language.en));
        for (Map.Entry<String, String> p : params.entrySet()) {
            text = text.replace("{" + p.getKey() + "}", p.getValue() == null ? "" : p.getValue());
        }
        return text;
    }
}
