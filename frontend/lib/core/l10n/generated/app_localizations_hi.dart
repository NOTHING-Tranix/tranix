// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ट्रानिक्स';

  @override
  String get tagline => 'सत्यापित सड़क माल ढुलाई';

  @override
  String get actionRetry => 'फिर से कोशिश करें';

  @override
  String get actionOk => 'ठीक है';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionConfirm => 'पुष्टि करें';

  @override
  String get actionSignUp => 'साइन अप करें';

  @override
  String get actionSignIn => 'साइन इन करें';

  @override
  String get actionSignOut => 'साइन आउट करें';

  @override
  String get actionContinue => 'आगे बढ़ें';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get stateLoading => 'लोड हो रहा है…';

  @override
  String get stateEmpty => 'अभी यहाँ कुछ नहीं है';

  @override
  String get stateOffline => 'आप ऑफ़लाइन हैं। कुछ जानकारी पुरानी हो सकती है।';

  @override
  String get comingSoon => 'यह स्क्रीन जल्द आ रही है।';

  @override
  String get demoTitle => 'डेमो (नमूना डेटा)';

  @override
  String demoOpenAs(String role) {
    return '$role के रूप में खोलें';
  }

  @override
  String get roleLoadProvider => 'लोड प्रदाता';

  @override
  String get roleFarmerNetwork => 'किसान नेटवर्क';

  @override
  String get roleDriver => 'ड्राइवर';

  @override
  String get roleOrganization => 'संगठन';

  @override
  String get roleReceiver => 'प्राप्तकर्ता';

  @override
  String get roleAdmin => 'एडमिन';

  @override
  String get navHome => 'होम';

  @override
  String get navTracking => 'ट्रैकिंग';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navWishlist => 'पसंदीदा सूची';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navFarmers => 'किसान';

  @override
  String get navSuggestions => 'सुझाव';

  @override
  String get navCurrentTrip => 'मौजूदा यात्रा';

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navTrucks => 'ट्रक';

  @override
  String get navDrivers => 'ड्राइवर';

  @override
  String get navTrips => 'यात्राएँ';

  @override
  String get navLoads => 'लोड';

  @override
  String get navNotifications => 'सूचनाएँ';

  @override
  String get loadStatusNotAccepted => 'स्वीकार नहीं हुआ';

  @override
  String get loadStatusAccepted => 'स्वीकार हुआ';

  @override
  String get loadStatusAmountNegotiation => 'राशि अनुरोध';

  @override
  String get loadStatusWaitingForPickup => 'पिकअप का इंतज़ार';

  @override
  String get loadStatusLocationReached => 'पिकअप स्थान पर पहुँचे';

  @override
  String get loadStatusPickedUp => 'माल उठाया गया';

  @override
  String get loadStatusTraveling => 'रास्ते में';

  @override
  String get loadStatusArrivedDestination => 'गंतव्य पर पहुँचे';

  @override
  String get loadStatusDelivered => 'डिलीवर हुआ';

  @override
  String get loadStatusCancelled => 'रद्द हुआ';

  @override
  String get paymentStatusPending => 'भुगतान बाकी';

  @override
  String get paymentStatusPaid => 'भुगतान हुआ';

  @override
  String get paymentStatusConfirmed => 'भुगतान की पुष्टि हुई';

  @override
  String get paymentStatusDisputed => 'विवादित';

  @override
  String get statusUnknown => 'अज्ञात';

  @override
  String get walletBalance => 'वॉलेट बैलेंस';

  @override
  String get trustScore => 'ट्रस्ट स्कोर';

  @override
  String get verificationBanner => 'शुरू करने के लिए सत्यापन पूरा करें';

  @override
  String get errorValidationFailed => 'कृपया चिह्नित फ़ील्ड जाँचें।';

  @override
  String get errorUnauthenticated => 'कृपया फिर से साइन इन करें।';

  @override
  String get errorTokenExpired =>
      'आपका सत्र समाप्त हो गया। कृपया फिर से साइन इन करें।';

  @override
  String get errorForbidden => 'आप यह नहीं कर सकते।';

  @override
  String get errorNotVerified => 'यह करने के लिए सत्यापन पूरा करें।';

  @override
  String get errorNotFound => 'यह नहीं मिला।';

  @override
  String get errorOtpInvalid => 'गलत OTP। जाँचकर फिर से कोशिश करें।';

  @override
  String get errorOtpExpired => 'यह OTP समाप्त हो गया। नया OTP माँगें।';

  @override
  String get errorOtpLocked => 'बहुत सारी गलत कोशिशें। 15 मिनट बाद कोशिश करें।';

  @override
  String get errorMobileInUse =>
      'इस नंबर पर पहले से खाता है। कृपया साइन इन करें।';

  @override
  String get errorInsufficientBalance =>
      'वॉलेट बैलेंस कम है। कृपया टॉप अप करें।';

  @override
  String get errorLoadTaken => 'किसी दूसरे ड्राइवर ने ले लिया।';

  @override
  String get errorInvalidState => 'यह अभी नहीं किया जा सकता।';

  @override
  String get errorRevisionLimitReached =>
      'इस यात्रा के सभी राशि अनुरोध इस्तेमाल हो चुके हैं।';

  @override
  String get errorRevisionPending =>
      'एक राशि अनुरोध पहले से जवाब का इंतज़ार कर रहा है।';

  @override
  String get errorAllocationConflict => 'यह ड्राइवर या ट्रक पहले से आवंटित है।';

  @override
  String get errorWishlistFull => 'आपकी पसंदीदा सूची भर गई है।';

  @override
  String get errorWishlistEmpty =>
      'आपकी पसंदीदा सूची में से कोई यह लोड नहीं ले सकता। सबको ऑफ़र करें या चुनाव बदलें।';

  @override
  String get errorRateLimited => 'बहुत सारी कोशिशें। कृपया थोड़ा रुकें।';

  @override
  String get errorNetwork => 'इंटरनेट कनेक्शन नहीं है। फिर से कोशिश करें।';

  @override
  String get errorTimeout => 'सर्वर बहुत समय ले रहा है। फिर से कोशिश करें।';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। फिर से कोशिश करें।';

  @override
  String get mobileLabel => 'मोबाइल नंबर';

  @override
  String get mobileInvalid => 'सही 10 अंकों का मोबाइल नंबर डालें';

  @override
  String get nameLabel => 'पूरा नाम';

  @override
  String get nameInvalid => 'नाम 2 से 60 अक्षरों का होना चाहिए';

  @override
  String get roleQuestion => 'मैं हूँ';

  @override
  String get roleRequired => 'चुनें कि आप कौन हैं';

  @override
  String get consentText =>
      'मैं उपयोग की शर्तें और गोपनीयता नीति स्वीकार करता/करती हूँ';

  @override
  String get consentRequired => 'आगे बढ़ने के लिए स्वीकार करें';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get otpTitle => 'OTP डालें';

  @override
  String otpSentTo(String mobile) {
    return '+91 $mobile पर 6 अंकों का कोड भेजा गया';
  }

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में फिर से भेजें';
  }

  @override
  String get resendOtp => 'OTP फिर से भेजें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get signInInstead => 'साइन इन करें';

  @override
  String get noAccount => 'ट्रानिक्स पर नए हैं? साइन अप करें';

  @override
  String get completeProfileBanner =>
      'शुरू करने के लिए अपनी प्रोफ़ाइल पूरी करें';

  @override
  String get otpSent => 'OTP भेजा गया';
}
