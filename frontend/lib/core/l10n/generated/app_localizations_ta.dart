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

  @override
  String get mobileLabel => 'மொபைல் எண்';

  @override
  String get mobileInvalid => 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get nameLabel => 'முழுப் பெயர்';

  @override
  String get nameInvalid => 'பெயர் 2 முதல் 60 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get roleQuestion => 'நான் ஒரு';

  @override
  String get roleRequired => 'நீங்கள் யார் என்பதைத் தேர்ந்தெடுக்கவும்';

  @override
  String get consentText =>
      'பயன்பாட்டு விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறேன்';

  @override
  String get consentRequired => 'தொடர ஏற்றுக்கொள்ளவும்';

  @override
  String get sendOtp => 'OTP அனுப்பு';

  @override
  String get otpTitle => 'OTP-ஐ உள்ளிடவும்';

  @override
  String otpSentTo(String mobile) {
    return '+91 $mobile எண்ணுக்கு 6 இலக்கக் குறியீடு அனுப்பப்பட்டது';
  }

  @override
  String resendIn(int seconds) {
    return '$seconds வினாடிகளில் மீண்டும் அனுப்பலாம்';
  }

  @override
  String get resendOtp => 'OTP-ஐ மீண்டும் அனுப்பு';

  @override
  String get verify => 'சரிபார்';

  @override
  String get signInInstead => 'உள்நுழையவும்';

  @override
  String get noAccount => 'டிரானிக்ஸில் புதியவரா? பதிவு செய்யவும்';

  @override
  String get completeProfileBanner => 'தொடங்க உங்கள் சுயவிவரத்தை முடிக்கவும்';

  @override
  String get otpSent => 'OTP அனுப்பப்பட்டது';

  @override
  String get photo => 'புகைப்படம்';

  @override
  String get addPhoto => 'புகைப்படம் சேர்';

  @override
  String get camera => 'கேமரா';

  @override
  String get gallery => 'கேலரி';

  @override
  String get pdfFile => 'PDF கோப்பு';

  @override
  String get basicDetails => 'பெயர், மின்னஞ்சல் மற்றும் முகவரி';

  @override
  String get emailLabel => 'மின்னஞ்சல் (விருப்பம்)';

  @override
  String get emailInvalid => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get address => 'முகவரி';

  @override
  String get addressLine => 'வீடு / தெரு';

  @override
  String get village => 'கிராமம் / நகரம்';

  @override
  String get district => 'மாவட்டம்';

  @override
  String get state => 'மாநிலம்';

  @override
  String get pinCode => 'பின் கோடு';

  @override
  String get pinInvalid => '6 இலக்க பின் கோடை உள்ளிடவும்';

  @override
  String get fieldRequired => 'தேவை';

  @override
  String get save => 'சேமி';

  @override
  String get saved => 'சேமிக்கப்பட்டது';

  @override
  String get language => 'மொழி';

  @override
  String get roleDetails => 'கணக்கு விவரங்கள்';

  @override
  String get idProof => 'அடையாளச் சான்று';

  @override
  String get documents => 'ஆவணங்கள்';

  @override
  String get changeMobile => 'மொபைல் எண்ணை மாற்று';

  @override
  String get newMobile => 'புதிய மொபைல் எண்';

  @override
  String get verificationTitle => 'சரிபார்ப்பு';

  @override
  String get submitForVerification => 'சரிபார்ப்புக்குச் சமர்ப்பி';

  @override
  String get statusNotSubmitted => 'சமர்ப்பிக்கப்படவில்லை';

  @override
  String get statusUnderReview => 'பரிசீலனையில்';

  @override
  String get statusVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get statusNotVerified => 'சரிபார்க்கப்படவில்லை';

  @override
  String underReviewInfo(int hours) {
    return 'உங்கள் விவரங்களைச் சரிபார்க்கிறோம். இதற்கு சுமார் $hours மணி நேரம் ஆகும்.';
  }

  @override
  String get notVerifiedInfo => 'சில ஆவணங்களை மீண்டும் பதிவேற்ற வேண்டும்.';

  @override
  String get verifiedInfo =>
      'நீங்கள் சரிபார்க்கப்பட்டீர்கள். இப்போது அனைத்து வசதிகளையும் பயன்படுத்தலாம்.';

  @override
  String get notSubmittedInfo =>
      'கீழே உள்ள அனைத்தையும் முடித்து, சரிபார்ப்புக்குச் சமர்ப்பிக்கவும்.';

  @override
  String get checkUpdates => 'புதுப்பிப்புகளைப் பார்';

  @override
  String get uploadAgain => 'மீண்டும் பதிவேற்று';

  @override
  String get docPan => 'பான் கார்டு';

  @override
  String get docVoterId => 'வாக்காளர் அடையாள அட்டை';

  @override
  String get docDrivingLicence => 'ஓட்டுநர் உரிமம்';

  @override
  String get docPhoto => 'புகைப்படம்';

  @override
  String get docFnRegistrationCert => 'பதிவுச் சான்றிதழ்';

  @override
  String get docOrgRegistrationCert => 'பதிவுச் சான்றிதழ்';

  @override
  String get docGstCert => 'GST சான்றிதழ்';

  @override
  String get docAadhaar => 'ஆதார் (ஆஃப்லைன் சரிபார்ப்பு)';

  @override
  String get docRc => 'RC புத்தகம்';

  @override
  String get docInsurance => 'காப்பீடு';

  @override
  String get docNationalPermit => 'தேசிய அனுமதி';

  @override
  String get documentType => 'ஆவணம்';

  @override
  String get docNumber => 'ஆவண எண்';

  @override
  String get expiresOn => 'செல்லுபடியாகும் தேதி';

  @override
  String get chooseFile => 'கோப்பைத் தேர்ந்தெடு';

  @override
  String uploading(int percent) {
    return 'பதிவேற்றுகிறது… $percent%';
  }

  @override
  String fileChosen(int count) {
    return '$count கோப்பு(கள்) தேர்ந்தெடுக்கப்பட்டன';
  }

  @override
  String get docPending => 'பரிசீலனைக்குக் காத்திருக்கிறது';

  @override
  String get docApproved => 'ஏற்கப்பட்டது';

  @override
  String get docRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String rejectedReason(String reason) {
    return 'காரணம்: $reason';
  }

  @override
  String expiresOnDate(String date) {
    return '$date வரை செல்லும்';
  }

  @override
  String get addDocument => 'ஆவணம் சேர்';

  @override
  String get completeVerificationTitle => 'சரிபார்ப்பை முடிக்கவும்';

  @override
  String get completeVerificationBody =>
      'இதைச் செய்ய சரிபார்க்கப்பட்ட கணக்கு தேவை. உங்கள் சுயவிவரத்தை முடித்து சரிபார்ப்புக்குச் சமர்ப்பிக்கவும்.';

  @override
  String get goToProfile => 'சுயவிவரத்திற்குச் செல்';

  @override
  String get accountType => 'கணக்கு வகை';

  @override
  String get individual => 'தனிநபர்';

  @override
  String get business => 'வணிகம்';

  @override
  String get businessName => 'வணிகப் பெயர்';

  @override
  String get businessNameOptional => 'வணிகப் பெயர் (விருப்பம்)';

  @override
  String get gstinOptional => 'GSTIN (விருப்பம்)';

  @override
  String get panOptional => 'PAN (விருப்பம்)';

  @override
  String get networkName => 'அமைப்பின் பெயர்';

  @override
  String get registrationNumber => 'பதிவு எண்';

  @override
  String get idType => 'அடையாள வகை';

  @override
  String get idNumber => 'அடையாள எண்';

  @override
  String get contactPerson => 'தொடர்பு நபர்';

  @override
  String get licenceNumber => 'உரிம எண்';

  @override
  String get licenceValidUntil => 'உரிமம் செல்லுபடியாகும் தேதி';

  @override
  String get vehicleClasses => 'வாகன வகைகள் (எ.கா. HGMV, LMV)';

  @override
  String get emergencyContact => 'அவசரத் தொடர்பு (விருப்பம்)';

  @override
  String get orgName => 'நிறுவனத்தின் பெயர்';

  @override
  String get pickDate => 'தேதியைத் தேர்ந்தெடு';

  @override
  String get wallet => 'வாலட்';

  @override
  String get support => 'உதவி';

  @override
  String get mobileChanged => 'மொபைல் எண் மாற்றப்பட்டது';
}
