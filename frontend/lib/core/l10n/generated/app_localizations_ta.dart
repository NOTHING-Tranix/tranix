// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'டிரானிக்ஸ்';

  @override
  String get tagline => 'சரிபார்க்கப்பட்ட சாலை சரக்கு';

  @override
  String get actionRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get actionOk => 'சரி';

  @override
  String get actionCancel => 'ரத்து செய்';

  @override
  String get actionConfirm => 'உறுதிசெய்';

  @override
  String get actionSignUp => 'பதிவு செய்';

  @override
  String get actionSignIn => 'உள்நுழை';

  @override
  String get actionSignOut => 'வெளியேறு';

  @override
  String get actionContinue => 'தொடர்க';

  @override
  String get chooseLanguage => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get stateLoading => 'ஏற்றுகிறது…';

  @override
  String get stateEmpty => 'இங்கு இன்னும் எதுவும் இல்லை';

  @override
  String get stateOffline =>
      'இணைய இணைப்பு இல்லை. சில தகவல்கள் பழையதாக இருக்கலாம்.';

  @override
  String get comingSoon => 'இந்தத் திரை விரைவில் வரும்.';

  @override
  String get demoTitle => 'டெமோ (மாதிரி தரவு)';

  @override
  String demoOpenAs(String role) {
    return '$role ஆகத் திற';
  }

  @override
  String get roleLoadProvider => 'சரக்கு அனுப்புநர்';

  @override
  String get roleFarmerNetwork => 'விவசாயிகள் அமைப்பு';

  @override
  String get roleDriver => 'ஓட்டுநர்';

  @override
  String get roleOrganization => 'நிறுவனம்';

  @override
  String get roleReceiver => 'பெறுநர்';

  @override
  String get roleAdmin => 'நிர்வாகி';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navTracking => 'கண்காணிப்பு';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navWishlist => 'விருப்பப் பட்டியல்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get navFarmers => 'விவசாயிகள்';

  @override
  String get navSuggestions => 'பரிந்துரைகள்';

  @override
  String get navCurrentTrip => 'தற்போதைய பயணம்';

  @override
  String get navDashboard => 'டாஷ்போர்டு';

  @override
  String get navTrucks => 'லாரிகள்';

  @override
  String get navDrivers => 'ஓட்டுநர்கள்';

  @override
  String get navTrips => 'பயணங்கள்';

  @override
  String get navLoads => 'சரக்குகள்';

  @override
  String get navNotifications => 'அறிவிப்புகள்';

  @override
  String get loadStatusNotAccepted => 'ஏற்கப்படவில்லை';

  @override
  String get loadStatusAccepted => 'ஏற்கப்பட்டது';

  @override
  String get loadStatusAmountNegotiation => 'தொகை கோரிக்கை';

  @override
  String get loadStatusWaitingForPickup => 'ஏற்றக் காத்திருக்கிறது';

  @override
  String get loadStatusLocationReached => 'ஏற்றும் இடத்தை அடைந்தது';

  @override
  String get loadStatusPickedUp => 'ஏற்றப்பட்டது';

  @override
  String get loadStatusTraveling => 'பயணத்தில்';

  @override
  String get loadStatusArrivedDestination => 'சேருமிடத்தை அடைந்தது';

  @override
  String get loadStatusDelivered => 'ஒப்படைக்கப்பட்டது';

  @override
  String get loadStatusCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get paymentStatusPending => 'கட்டணம் நிலுவையில்';

  @override
  String get paymentStatusPaid => 'செலுத்தப்பட்டது';

  @override
  String get paymentStatusConfirmed => 'கட்டணம் உறுதிசெய்யப்பட்டது';

  @override
  String get paymentStatusDisputed => 'சர்ச்சையில்';

  @override
  String get statusUnknown => 'தெரியவில்லை';

  @override
  String get walletBalance => 'வாலட் இருப்பு';

  @override
  String get trustScore => 'நம்பிக்கை மதிப்பெண்';

  @override
  String get verificationBanner => 'தொடங்க சரிபார்ப்பை முடிக்கவும்';

  @override
  String get errorValidationFailed =>
      'குறிக்கப்பட்ட புலங்களைச் சரிபார்க்கவும்.';

  @override
  String get errorUnauthenticated => 'மீண்டும் உள்நுழையவும்.';

  @override
  String get errorTokenExpired =>
      'உங்கள் அமர்வு காலாவதியானது. மீண்டும் உள்நுழையவும்.';

  @override
  String get errorForbidden => 'இதைச் செய்ய உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get errorNotVerified => 'இதைச் செய்ய சரிபார்ப்பை முடிக்கவும்.';

  @override
  String get errorNotFound => 'இதைக் கண்டுபிடிக்க முடியவில்லை.';

  @override
  String get errorOtpInvalid =>
      'தவறான OTP. சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorOtpExpired => 'இந்த OTP காலாவதியானது. புதியதைக் கேளுங்கள்.';

  @override
  String get errorOtpLocked =>
      'பல தவறான முயற்சிகள். 15 நிமிடங்கள் கழித்து முயற்சிக்கவும்.';

  @override
  String get errorMobileInUse =>
      'இந்த எண்ணில் ஏற்கனவே கணக்கு உள்ளது. உள்நுழையவும்.';

  @override
  String get errorInsufficientBalance =>
      'வாலட் இருப்பு குறைவு. டாப் அப் செய்யவும்.';

  @override
  String get errorLoadTaken => 'வேறு ஓட்டுநர் ஏற்றுக்கொண்டார்.';

  @override
  String get errorInvalidState => 'இதை இப்போது செய்ய முடியாது.';

  @override
  String get errorRevisionLimitReached =>
      'இந்தப் பயணத்திற்கான அனைத்து தொகை கோரிக்கைகளும் பயன்படுத்தப்பட்டன.';

  @override
  String get errorRevisionPending =>
      'ஒரு தொகை கோரிக்கை ஏற்கனவே பதிலுக்குக் காத்திருக்கிறது.';

  @override
  String get errorAllocationConflict =>
      'இந்த ஓட்டுநர் அல்லது லாரி ஏற்கனவே ஒதுக்கப்பட்டுள்ளது.';

  @override
  String get errorWishlistFull => 'உங்கள் விருப்பப் பட்டியல் நிரம்பியுள்ளது.';

  @override
  String get errorWishlistEmpty =>
      'உங்கள் விருப்பப் பட்டியலில் யாரும் இந்தச் சரக்கை எடுக்க முடியாது. அனைவருக்கும் வழங்கவும் அல்லது தேர்வை மாற்றவும்.';

  @override
  String get errorRateLimited => 'பல முயற்சிகள். சிறிது நேரம் காத்திருக்கவும்.';

  @override
  String get errorNetwork => 'இணைய இணைப்பு இல்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorTimeout =>
      'சர்வர் பதிலளிக்க அதிக நேரம் எடுக்கிறது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorGeneric => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';
}
