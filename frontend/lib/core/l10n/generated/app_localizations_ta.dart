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
  String get addPhoto => 'படம் சேர்';

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

  @override
  String postingChargeIs(int amount) {
    return 'பதிவுக் கட்டணம் ₹$amount';
  }

  @override
  String tripChargeIs(int amount) {
    return 'பயணக் கட்டணம் ₹$amount';
  }

  @override
  String get lowBalanceWarning =>
      'இருப்பு குறைவு. தொடர்ந்து பயன்படுத்த டாப் அப் செய்யவும்.';

  @override
  String get topUp => 'டாப் அப்';

  @override
  String get otherAmount => 'வேறு தொகை (₹)';

  @override
  String get amountInvalid => 'தொகையை உள்ளிடவும்';

  @override
  String get transactions => 'பரிவர்த்தனைகள்';

  @override
  String get allTypes => 'அனைத்தும்';

  @override
  String get txnTopup => 'டாப் அப்';

  @override
  String get txnPostingCharge => 'பதிவுக் கட்டணம்';

  @override
  String get txnTripCharge => 'பயணக் கட்டணம்';

  @override
  String get txnRefund => 'திருப்பித் தொகை';

  @override
  String get txnAdminCredit => 'டிரானிக்ஸ் வரவு';

  @override
  String get month => 'மாதம்';

  @override
  String get downloadStatement => 'அறிக்கையைப் பதிவிறக்கு';

  @override
  String get statementSaved => 'அறிக்கை சேமிக்கப்பட்டது';

  @override
  String get noTransactions => 'இன்னும் பரிவர்த்தனைகள் இல்லை';

  @override
  String get openingPayment =>
      'உலாவியில் பணம் செலுத்தி, பிறகு திரும்பி வரவும்.';

  @override
  String get tabTrips => 'பயணங்கள்';

  @override
  String get tabWallet => 'வாலட்';

  @override
  String get tabTranix => 'டிரானிக்ஸ்';

  @override
  String get tabAccount => 'கணக்கு';

  @override
  String get markAllRead => 'அனைத்தையும் படித்ததாகக் குறி';

  @override
  String get noNotifications => 'அறிவிப்புகள் இல்லை';

  @override
  String get latestTranixMessage => 'டிரானிக்ஸிடமிருந்து';

  @override
  String get latestTripUpdate => 'சமீபத்திய பயணப் புதுப்பிப்பு';

  @override
  String get postLoad => 'சரக்கைப் பதிவு செய்';

  @override
  String get pickupSection => 'ஏற்றும் இடம்';

  @override
  String get goodsSection => 'சரக்கு';

  @override
  String get dropSection => 'இறக்கும் இடம்';

  @override
  String get receiverSection => 'பெறுநர்';

  @override
  String get paymentSection => 'கட்டணம்';

  @override
  String get offerTo => 'யாருக்கு வழங்க';

  @override
  String get pickupDate => 'ஏற்றும் தேதி';

  @override
  String get windowFrom => 'முதல்';

  @override
  String get windowTo => 'வரை';

  @override
  String get setLocation => 'இடத்தை அமை';

  @override
  String get useCurrentLocation => 'என் தற்போதைய இடத்தைப் பயன்படுத்து';

  @override
  String get locationNotSet => 'இடம் அமைக்கப்படவில்லை';

  @override
  String get addressLabel => 'முகவரி';

  @override
  String get landmarkOptional => 'அடையாளக் குறி (விருப்பம்)';

  @override
  String get senderName => 'அனுப்புநர் பெயர்';

  @override
  String get senderMobile => 'அனுப்புநர் மொபைல்';

  @override
  String get goodsType => 'சரக்கு வகை';

  @override
  String get descriptionOptional => 'விவரம் (விருப்பம்)';

  @override
  String get quantity => 'அளவு';

  @override
  String get unit => 'அலகு';

  @override
  String get weightTonnes => 'தோராய எடை (டன்)';

  @override
  String get vehicleType => 'வாகன வகை';

  @override
  String get receiverName => 'பெறுநர் பெயர்';

  @override
  String get receiverMobile => 'பெறுநர் மொபைல்';

  @override
  String get freightPaidBy => 'சரக்குக் கட்டணம் செலுத்துபவர்';

  @override
  String get paidByMe => 'நான்';

  @override
  String get paidByReceiver => 'பெறுநர்';

  @override
  String get amountInr => 'தொகை (₹)';

  @override
  String suggestedRange(String min, String max) {
    return 'ஒத்த பயணங்கள்: $min – $max';
  }

  @override
  String estimateLine(String km, String hours, String eta) {
    return '$km · $hours மணி பயணம் · $eta-க்குள் சேரும்';
  }

  @override
  String get offerEveryone => 'அனைவருக்கும்';

  @override
  String get offerWishlistFirst =>
      'முதலில் விருப்பப் பட்டியல் (15 நிமிடம், பின் அனைவருக்கும்)';

  @override
  String get offerWishlistOnly => 'விருப்பப் பட்டியலுக்கு மட்டும்';

  @override
  String get reviewTitle => 'சரிபார்';

  @override
  String postingChargeNote(String amount) {
    return 'பதிவுக் கட்டணம் $amount — ஓட்டுநர் ஏற்றுக்கொண்டால் மட்டுமே';
  }

  @override
  String get confirmPost => 'சரக்கைப் பதிவு செய்';

  @override
  String get posted => 'சரக்கு பதிவு செய்யப்பட்டது';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String topUpToPost(String amount) {
    return 'பதிவு செய்ய $amount டாப் அப் செய்யவும்';
  }

  @override
  String get editLoad => 'திருத்து';

  @override
  String get cancelLoad => 'சரக்கை ரத்து செய்';

  @override
  String get cancelReason => 'காரணம்';

  @override
  String get noteLabel => 'குறிப்பு';

  @override
  String get cancelOutcomeFree =>
      'கட்டணம் இல்லை. நம்பிக்கை மதிப்பெண் பாதிக்காது.';

  @override
  String cancelOutcomeKept(String points) {
    return 'கட்டணம் திருப்பித் தரப்படாது. மற்றவர் தவறு இல்லையெனில் நம்பிக்கை மதிப்பெண் $points.';
  }

  @override
  String get cancelSupportOnly =>
      'ஏற்றிய பிறகு உதவி மையம் மூலம் மட்டுமே ரத்து செய்யலாம்.';

  @override
  String get postAgain => 'மீண்டும் பதிவு செய்';

  @override
  String get timeline => 'நிலை வரலாறு';

  @override
  String get deliveryEstimate => 'சேரும் நேரம் (மதிப்பீடு)';

  @override
  String get ongoingLoads => 'நடப்பு சரக்குகள்';

  @override
  String get noLoads => 'இன்னும் சரக்குகள் இல்லை';

  @override
  String get unitBags => 'மூட்டைகள்';

  @override
  String get unitCrates => 'கிரேட்கள்';

  @override
  String get unitBoxes => 'பெட்டிகள்';

  @override
  String get unitTonnes => 'டன்';

  @override
  String get unitLitres => 'லிட்டர்';

  @override
  String get vehOpenBody => 'திறந்த பாடி';

  @override
  String get vehClosedBody => 'மூடிய பாடி';

  @override
  String get vehContainer => 'கண்டெய்னர்';

  @override
  String get vehRefrigerated => 'குளிர்சாதன வாகனம்';

  @override
  String get vehTanker => 'டேங்கர்';

  @override
  String get vehAny => 'ஏதேனும்';

  @override
  String get crPlansChanged => 'என் திட்டம் மாறியது';

  @override
  String get crGoodsNotReady => 'சரக்கு தயாராக இல்லை';

  @override
  String get crFoundOtherTruck => 'வேறு லாரி கிடைத்தது';

  @override
  String get crDriverNotReachable => 'ஓட்டுநரைத் தொடர்பு கொள்ள முடியவில்லை';

  @override
  String get crDriverDidNotCome => 'ஓட்டுநர் வரவில்லை';

  @override
  String get crDriverAskedMore => 'ஓட்டுநர் அதிகப் பணம் கேட்டார்';

  @override
  String get crTruckBreakdown => 'லாரி பழுது';

  @override
  String get crEmergency => 'அவசரம்';

  @override
  String get crShipperChangedDetails => 'அனுப்புநர் விவரங்களை மாற்றினார்';

  @override
  String get crAmountNotAgreed => 'தொகை ஒப்புக்கொள்ளப்படவில்லை';

  @override
  String get crTooFar => 'மிகத் தொலைவு';

  @override
  String get crOther => 'மற்றவை';

  @override
  String get loadDetails => 'சரக்கு விவரங்கள்';

  @override
  String get sender => 'அனுப்புநர்';

  @override
  String get receiver => 'பெறுநர்';

  @override
  String get onDuty => 'பணியில்';

  @override
  String get offDuty => 'பணியில் இல்லை';

  @override
  String get goOnDutyHint => 'பயணப் பரிந்துரைகள் பெற பணியில் இருங்கள்';

  @override
  String get myTruck => 'என் லாரி';

  @override
  String get addTruck => 'என் லாரியைச் சேர்';

  @override
  String get truckNumber => 'லாரி எண்';

  @override
  String get capacityTonnes => 'கொள்ளளவு (டன்)';

  @override
  String get truckAvailable => 'கிடைக்கிறது';

  @override
  String get truckAllocated => 'ஒதுக்கப்பட்டது';

  @override
  String get truckOnTrip => 'பயணத்தில்';

  @override
  String get truckDocumentsPending => 'ஆவணங்கள் நிலுவையில்';

  @override
  String get truckInactive => 'செயலில் இல்லை';

  @override
  String get truckDocuments => 'லாரி ஆவணங்கள்';

  @override
  String invitationFrom(String org) {
    return '$org உங்களை ஓட்டுநராக அழைத்துள்ளது';
  }

  @override
  String get accept => 'ஏற்கவும்';

  @override
  String get reject => 'நிராகரி';

  @override
  String suggestionsAvailable(int count) {
    return '$count பயணப் பரிந்துரைகள்';
  }

  @override
  String get expiringDocs => 'விரைவில் காலாவதியாகும் ஆவணங்கள்';

  @override
  String get locker => 'ஆவணப் பெட்டகம்';

  @override
  String truckAssignedBy(String org) {
    return '$org ஒதுக்கிய லாரி';
  }

  @override
  String get openTrip => 'தற்போதைய பயணத்தைத் திற';

  @override
  String get noTruckYet => 'இன்னும் லாரி இல்லை';

  @override
  String get invitations => 'நிறுவன அழைப்புகள்';

  @override
  String get sortNearest => 'அருகில்';

  @override
  String get sortAmount => 'தொகை';

  @override
  String get sortEarliest => 'முதலில்';

  @override
  String get acceptTrip => 'ஏற்கவும்';

  @override
  String get acceptConfirmTitle => 'இந்தப் பயணத்தை ஏற்கவா?';

  @override
  String acceptConfirmBody(String amount, String charge) {
    return 'தொகை $amount. பயணக் கட்டணம் $charge இப்போது கழிக்கப்படும்.';
  }

  @override
  String get rejectTrip => 'வேண்டாம்';

  @override
  String get rejectWhy => 'ஏன் வேண்டாம்?';

  @override
  String get rrTooFar => 'மிகத் தொலைவு';

  @override
  String get rrLowAmount => 'தொகை குறைவு';

  @override
  String get rrWrongTruck => 'தவறான லாரி';

  @override
  String get preferredTag => 'இந்த அனுப்புநர் உங்களை விரும்புகிறார்';

  @override
  String toPickup(String km, int minutes) {
    return '$km தொலைவு · ஏற்றும் இடத்திற்கு $minutes நிமிடம்';
  }

  @override
  String get topUpToSeeTrips => 'பயணங்களைப் பார்க்க டாப் அப் செய்யவும்';

  @override
  String get noSuggestions =>
      'இப்போது பயணங்கள் இல்லை. சில நிமிடங்களில் புதியவை வரும்.';

  @override
  String get driverSection => 'ஓட்டுநர்';

  @override
  String get callAction => 'அழை';

  @override
  String get tripAccepted => 'பயணம் ஏற்கப்பட்டது';

  @override
  String get stepReachedPickup => 'ஏற்றும் இடத்தை அடைந்தேன்';

  @override
  String get stepEnterPickupOtp => 'ஏற்றும் OTP-ஐ உள்ளிடு';

  @override
  String get stepReachedDrop => 'சேருமிடத்தை அடைந்தேன்';

  @override
  String get stepEnterDeliveryOtp => 'ஒப்படைப்பு OTP-ஐ உள்ளிடு';

  @override
  String get navigate => 'வழிகாட்டு';

  @override
  String get requestAmount => 'புதிய தொகை கேள்';

  @override
  String amountUsed(int used, int limit) {
    return '$limit-ல் $used பயன்படுத்தப்பட்டது';
  }

  @override
  String get amountPendingWait => 'அனுப்புநரின் பதிலுக்குக் காத்திருக்கிறது';

  @override
  String get newAmount => 'புதிய தொகை (₹)';

  @override
  String get reasonLabel => 'காரணம்';

  @override
  String get sendAction => 'அனுப்பு';

  @override
  String get cancelTrip => 'பயணத்தை ரத்து செய்';

  @override
  String outsideRadiusTitle(int meters) {
    return 'நீங்கள் குறியிலிருந்து $meters மீ தொலைவில் உள்ளீர்கள்';
  }

  @override
  String get outsideRadiusBody =>
      'குறியிடப்பட்ட இடத்தில் ஏன் இல்லை என்று சொல்லுங்கள்.';

  @override
  String get otpAskSender => 'அனுப்புநரிடம் 6 இலக்கக் குறியீட்டைக் கேளுங்கள்';

  @override
  String get otpAskReceiver => 'பெறுநரிடம் 6 இலக்கக் குறியீட்டைக் கேளுங்கள்';

  @override
  String otpSentToMobile(String mobile) {
    return '$mobile-க்கு அனுப்பப்பட்டது';
  }

  @override
  String get cantGetOtp => 'OTP கிடைக்கவில்லையா?';

  @override
  String get helpNote => 'என்ன நடந்தது?';

  @override
  String get helpSent =>
      'உதவி கோரிக்கை அனுப்பப்பட்டது. டிரானிக்ஸ் உங்களை அழைக்கும்.';

  @override
  String get noActiveTrip =>
      'தற்போது பயணம் இல்லை. பரிந்துரையை ஏற்றுத் தொடங்குங்கள்.';

  @override
  String get locationExplainTitle => 'பயணத்தின்போது உங்கள் இடத்தைப் பகிரவும்';

  @override
  String get locationExplainBody =>
      'பயணம் நடக்கும்போது மட்டுமே டிரானிக்ஸ் உங்கள் இடத்தைப் பயன்படுத்துகிறது, அதனால் அனுப்புநரும் பெறுநரும் லாரியைப் பார்க்கலாம். அப்போது ஒரு அறிவிப்பு தெரியும்.';

  @override
  String get allow => 'அனுமதி';

  @override
  String tripInProgress(String code) {
    return 'டிரானிக்ஸ் பயணம் $code நடக்கிறது';
  }

  @override
  String get layerPetrol => 'பெட்ரோல்';

  @override
  String get layerWeighbridge => 'எடை மேடை';

  @override
  String get layerPuncture => 'பஞ்சர்';

  @override
  String get layerToll => 'சுங்கச்சாவடி';

  @override
  String get layerRestrictions => 'கட்டுப்பாடுகள்';

  @override
  String noEntryHours(String from, String to) {
    return 'நுழைவு இல்லை $from–$to';
  }

  @override
  String get amountRequestTitle => 'தொகை கோரிக்கை';

  @override
  String amountRequestBody(String amount, String reason) {
    return 'ஓட்டுநர் $amount கேட்கிறார்: $reason';
  }

  @override
  String answerBy(String time) {
    return '$time-க்குள் பதிலளிக்கவும்';
  }

  @override
  String get rejectKeepsAmount =>
      'நிராகரித்தால் தற்போதைய தொகையே இருக்கும்; பயணம் தொடரும்.';

  @override
  String get pickupOtpTitle => 'ஏற்றும் OTP';

  @override
  String get deliveryOtpTitle => 'ஒப்படைப்பு OTP';

  @override
  String get shareAfterLoading =>
      'ஏற்றிய பின் இந்தக் குறியீட்டை ஓட்டுநரிடம் கூறவும்.';

  @override
  String get shareAfterChecking => 'சரக்கைச் சரிபார்த்த பின் மட்டுமே பகிரவும்.';

  @override
  String get liveTracking => 'நேரடி கண்காணிப்பு';

  @override
  String lastSeen(String time) {
    return 'லாரி $time-க்குப் பார்க்கப்பட்டது';
  }

  @override
  String get routeNormal => 'நேரத்தில்';

  @override
  String get routeSlow => 'தாமதம்';

  @override
  String get routeFast => 'வேகமாக';

  @override
  String etaAt(String time) {
    return 'வரும் நேரம் $time';
  }

  @override
  String get pickupAt => 'ஏற்றும் இடம்';

  @override
  String get dropAt => 'இறக்கும் இடம்';

  @override
  String get callSender => 'அனுப்புநரை அழை';

  @override
  String get callReceiver => 'பெறுநரை அழை';

  @override
  String get callShipper => 'சரக்கு உரிமையாளரை அழை';

  @override
  String get markPaid => 'செலுத்தியதாகக் குறி';

  @override
  String get paymentMode => 'முறை';

  @override
  String get modeCash => 'பணம்';

  @override
  String get modeUpi => 'UPI';

  @override
  String get modeBank => 'வங்கி';

  @override
  String get referenceOptional => 'குறிப்பு எண் (விருப்பம்)';

  @override
  String get confirmReceived => 'பெற்றேன் என உறுதிசெய்';

  @override
  String get disputePayment => 'சர்ச்சை';

  @override
  String get disputeReason => 'என்ன பிரச்சனை?';

  @override
  String paidVia(String amount, String mode) {
    return '$amount - $mode';
  }

  @override
  String get thisMonth => 'இந்த மாதம்';

  @override
  String tripsCount(int count) {
    return '$count பயணங்கள்';
  }

  @override
  String get agreedTotal => 'ஒப்புக்கொண்டது';

  @override
  String get receivedTotal => 'பெற்றது';

  @override
  String get pendingTotal => 'நிலுவை';

  @override
  String rateTitle(String name) {
    return '$name-ஐ மதிப்பிடுங்கள்';
  }

  @override
  String get rateLater => 'பின்னர்';

  @override
  String get submitAction => 'சமர்ப்பி';

  @override
  String get commentOptional => 'கருத்து (விருப்பம்)';

  @override
  String get howItWorks => 'இது எப்படி வேலை செய்கிறது';

  @override
  String get trustHowBody =>
      'உங்கள் மதிப்பெண் 70-ல் (100-க்கு) தொடங்கும். நேரத்தில் பயணம், நல்ல மதிப்பீடு, நேரத்தில் கட்டணம் உயர்த்தும்; தாமதம், ஏற்ற பின் ரத்து, சர்ச்சையில் தோல்வி குறைக்கும்.';

  @override
  String get noEvents => 'இன்னும் மாற்றங்கள் இல்லை';

  @override
  String get evOnTime => 'நேரத்தில் பயணம்';

  @override
  String get evLateDelivery => 'தாமதமான ஒப்படைப்பு';

  @override
  String get evLatePickup => 'தாமதமான ஏற்றம்';

  @override
  String get evCancelled => 'ஏற்ற பின் ரத்து';

  @override
  String get evRating => 'மதிப்பீடு பெற்றது';

  @override
  String get evPaymentOnTime => 'நேரத்தில் கட்டணம்';

  @override
  String get evDisputeLost => 'சர்ச்சையில் தோல்வி';

  @override
  String get evAdmin => 'டிரானிக்ஸ் மாற்றம்';

  @override
  String get evComplaint => 'உறுதிசெய்யப்பட்ட புகார்';

  @override
  String get evDriverCancelled => 'ஓட்டுநர் ரத்து செய்தார்';

  @override
  String get myList => 'என் பட்டியல்';

  @override
  String get fromMyTrips => 'என் பயணங்களிலிருந்து';

  @override
  String get findOrganization => 'நிறுவனத்தைத் தேடு';

  @override
  String get searchOrgHint => 'நிறுவனப் பெயர் அல்லது குறியீடு';

  @override
  String get addToWishlist => 'விருப்பப் பட்டியலில் சேர்';

  @override
  String get addedToWishlist => 'விருப்பப் பட்டியலில் சேர்க்கப்பட்டது';

  @override
  String wishlistCount(int count, int max) {
    return '$count / $max';
  }

  @override
  String tripsTogether(int count) {
    return '$count பயணங்கள் ஒன்றாக';
  }

  @override
  String get availableNow => 'இப்போது கிடைக்கும்';

  @override
  String get removeAction => 'நீக்கு';

  @override
  String get wishlistEmptyHint =>
      'உங்கள் பழைய பயணங்களிலிருந்து லாரிகளைச் சேர்க்கவும் அல்லது சரிபார்க்கப்பட்ட நிறுவனங்களைத் தேடவும்.';

  @override
  String get noCandidates => 'உங்கள் பயணங்களிலிருந்து சேர்க்க எதுவும் இல்லை.';

  @override
  String get chooseEntries => 'முதலில் யாருக்கு';

  @override
  String get manageWishlist => 'விருப்பப் பட்டியலை நிர்வகி';

  @override
  String wishlistFirstBanner(String time) {
    return '$time வரை உங்கள் விருப்பப் பட்டியலுக்கு மட்டும், பிறகு அனைவருக்கும்.';
  }

  @override
  String get wishlistOnlyBanner => 'உங்கள் விருப்பப் பட்டியலுக்கு மட்டும்.';

  @override
  String get openToEveryone => 'அனைவருக்கும் திற';

  @override
  String trucksCount(int count) {
    return '$count லாரிகள்';
  }

  @override
  String get organizationLabel => 'நிறுவனம்';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String get idNumberInvalid => 'தேர்ந்த அடையாள வகைக்கு பொருந்தவில்லை';

  @override
  String get addFarmer => 'விவசாயியைச் சேர்';

  @override
  String get editFarmer => 'விவசாயியைத் திருத்து';

  @override
  String get aadhaarLast4Optional => 'ஆதார் கடைசி 4 இலக்கங்கள் (விருப்பம்)';

  @override
  String get aadhaarLast4Invalid => 'கடைசி 4 இலக்கங்களை மட்டும் உள்ளிடவும்';

  @override
  String get landAcresOptional => 'நிலம் (ஏக்கர், விருப்பம்)';

  @override
  String get farmerConsent =>
      'இந்த விவரங்களை டிரானிக்ஸுடன் பகிர விவசாயி ஒப்புக்கொண்டார்';

  @override
  String get deactivate => 'செயலிழக்கச் செய்';

  @override
  String get inactive => 'செயலில் இல்லை';

  @override
  String get noFarmers =>
      'இன்னும் விவசாயிகள் இல்லை. முதல் விவசாயியைச் சேர்க்கவும்.';

  @override
  String get searchFarmers => 'பெயர், மொபைல் அல்லது ஊர் மூலம் தேடு';

  @override
  String get postForFarmer => 'விவசாயிக்காகப் பதிவு செய்';

  @override
  String get chooseFarmer => 'விவசாயியைத் தேர்வு செய்';

  @override
  String postedFor(String name) {
    return '$name-க்காக';
  }

  @override
  String get allFarmers => 'அனைத்து விவசாயிகள்';

  @override
  String get senderLockedFarmer =>
      'விவசாயியே அனுப்புநர்; ஏற்றும் OTP அவருக்குச் செல்லும்.';

  @override
  String get activeTrips => 'நடப்பு பயணங்கள்';

  @override
  String get shippersPreferYou => 'உங்களை விரும்பும் அனுப்புநர்கள்';

  @override
  String get idleLabel => 'காலியாக';

  @override
  String get docsExpiringSoon => '30 நாளில் காலாவதியாகும் ஆவணங்கள்';

  @override
  String get notAllocated => 'ஒதுக்கப்படவில்லை';

  @override
  String get addOrgTruck => 'லாரியைச் சேர்';

  @override
  String get inviteDriver => 'ஓட்டுநரை அழை';

  @override
  String get invitedLabel => 'அழைக்கப்பட்டார் — சேர காத்திருப்பு';

  @override
  String get allocateAction => 'லாரியை ஒதுக்கு';

  @override
  String get pauseAction => 'நிறுத்து';

  @override
  String get resumeAction => 'தொடர்';

  @override
  String get pausedLabel => 'நிறுத்தப்பட்டது';

  @override
  String get removeAllocation => 'ஒதுக்கீட்டை நீக்கு';

  @override
  String get performanceTitle => 'செயல்திறன்';

  @override
  String onTimePct(int pct) {
    return '$pct% நேரத்தில்';
  }

  @override
  String get earnedLabel => 'சம்பாதித்தது';

  @override
  String get cancellationsLabel => 'ரத்துகள்';

  @override
  String get byDriver => 'ஓட்டுநர் வாரியாக';

  @override
  String get byTruck => 'லாரி வாரியாக';

  @override
  String get exportCsv => 'CSV ஏற்றுமதி';

  @override
  String get csvSaved => 'பயணங்கள் CSV ஆக சேமிக்கப்பட்டன';

  @override
  String lastSeenAt(String time) {
    return 'கடைசியாக $time';
  }

  @override
  String get noLiveLocation => 'நேரடி இருப்பிடம் இல்லை (பயணத்தில் இல்லை)';

  @override
  String get chooseTruck => 'லாரியைத் தேர்வு செய்';

  @override
  String get chooseDriver => 'ஓட்டுநரைத் தேர்வு செய்';

  @override
  String get deactivateTruck => 'லாரியைச் செயலிழக்கச் செய்';

  @override
  String get noTrucksYet =>
      'இன்னும் லாரிகள் இல்லை. முதல் லாரியைச் சேர்க்கவும்.';

  @override
  String get noDriversYet =>
      'இன்னும் ஓட்டுநர்கள் இல்லை. முதல் ஓட்டுநரை அழைக்கவும்.';

  @override
  String get noTrips => 'இன்னும் பயணங்கள் இல்லை';

  @override
  String get allItems => 'அனைத்தும்';

  @override
  String get incomingLoads => 'வரும் சரக்குகள்';

  @override
  String get noIncomingLoads => 'உங்களுக்கு வரும் சரக்குகள் இல்லை.';

  @override
  String get receiptTitle => 'பெற்றதற்கான ரசீது';

  @override
  String get receiptPhotos => 'ரசீது படங்கள் (1 முதல் 5)';

  @override
  String get conditionFull => 'முழுமையாகப் பெற்றேன்';

  @override
  String get conditionDamage => 'குறைவு அல்லது சேதம்';

  @override
  String get remarksLabel => 'குறிப்பு';

  @override
  String get remarksRequired => 'குறைவு அல்லது சேதத்தை விவரிக்கவும்';

  @override
  String get receiptSent => 'ரசீது அனுப்பப்பட்டது';

  @override
  String expectedDelivery(String time) {
    return 'எதிர்பார்ப்பு $time';
  }

  @override
  String get newTicket => 'புதிய கோரிக்கை';

  @override
  String get noTickets => 'இன்னும் உதவி கோரிக்கைகள் இல்லை.';

  @override
  String get ticketType => 'வகை';

  @override
  String get ticketComplaint => 'புகார்';

  @override
  String get ticketFeedback => 'கருத்து';

  @override
  String get ticketWallet => 'வாலெட்';

  @override
  String get ticketPaymentDispute => 'கட்டண சர்ச்சை';

  @override
  String get ticketOthers => 'மற்றவை';

  @override
  String get otherTopic => 'எதைப் பற்றி?';

  @override
  String get tripOptional => 'பயணம் (விருப்பம்)';

  @override
  String get tripRequired => 'பயணம்';

  @override
  String get descriptionLabel => 'விவரம்';

  @override
  String get photosUpTo3 => 'படங்கள் (3 வரை)';

  @override
  String get writeMessage => 'செய்தி எழுதுங்கள்';

  @override
  String get reopenAction => 'மீண்டும் திற';

  @override
  String get ticketOpen => 'திறந்துள்ளது';

  @override
  String get ticketClosed => 'மூடப்பட்டது';

  @override
  String closedReason(String reason) {
    return 'மூடப்பட்டது: $reason';
  }

  @override
  String get youLabel => 'நீங்கள்';

  @override
  String get tranixSupport => 'டிரானிக்ஸ் உதவி மையம்';

  @override
  String get ticketCreated => 'கோரிக்கை அனுப்பப்பட்டது. இங்கே பதில் வரும்.';
}
