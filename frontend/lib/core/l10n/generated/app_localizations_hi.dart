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

  @override
  String get photo => 'फ़ोटो';

  @override
  String get addPhoto => 'फ़ोटो जोड़ें';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get pdfFile => 'PDF फ़ाइल';

  @override
  String get basicDetails => 'नाम, ईमेल और पता';

  @override
  String get emailLabel => 'ईमेल (वैकल्पिक)';

  @override
  String get emailInvalid => 'सही ईमेल डालें';

  @override
  String get address => 'पता';

  @override
  String get addressLine => 'मकान / गली';

  @override
  String get village => 'गाँव / शहर';

  @override
  String get district => 'ज़िला';

  @override
  String get state => 'राज्य';

  @override
  String get pinCode => 'पिन कोड';

  @override
  String get pinInvalid => '6 अंकों का पिन कोड डालें';

  @override
  String get fieldRequired => 'ज़रूरी';

  @override
  String get save => 'सेव करें';

  @override
  String get saved => 'सेव हो गया';

  @override
  String get language => 'भाषा';

  @override
  String get roleDetails => 'खाते का विवरण';

  @override
  String get idProof => 'पहचान पत्र';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get changeMobile => 'मोबाइल नंबर बदलें';

  @override
  String get newMobile => 'नया मोबाइल नंबर';

  @override
  String get verificationTitle => 'सत्यापन';

  @override
  String get submitForVerification => 'सत्यापन के लिए भेजें';

  @override
  String get statusNotSubmitted => 'नहीं भेजा गया';

  @override
  String get statusUnderReview => 'जाँच जारी है';

  @override
  String get statusVerified => 'सत्यापित';

  @override
  String get statusNotVerified => 'सत्यापित नहीं';

  @override
  String underReviewInfo(int hours) {
    return 'हम आपका विवरण जाँच रहे हैं। इसमें आमतौर पर लगभग $hours घंटे लगते हैं।';
  }

  @override
  String get notVerifiedInfo => 'कुछ दस्तावेज़ फिर से अपलोड करने होंगे।';

  @override
  String get verifiedInfo =>
      'आप सत्यापित हैं। अब आप सभी सुविधाएँ इस्तेमाल कर सकते हैं।';

  @override
  String get notSubmittedInfo =>
      'नीचे दी गई सभी चीज़ें पूरी करें, फिर सत्यापन के लिए भेजें।';

  @override
  String get checkUpdates => 'अपडेट देखें';

  @override
  String get uploadAgain => 'फिर से अपलोड करें';

  @override
  String get docPan => 'पैन कार्ड';

  @override
  String get docVoterId => 'वोटर आईडी';

  @override
  String get docDrivingLicence => 'ड्राइविंग लाइसेंस';

  @override
  String get docPhoto => 'फ़ोटो';

  @override
  String get docFnRegistrationCert => 'पंजीकरण प्रमाणपत्र';

  @override
  String get docOrgRegistrationCert => 'पंजीकरण प्रमाणपत्र';

  @override
  String get docGstCert => 'GST प्रमाणपत्र';

  @override
  String get docAadhaar => 'आधार (ऑफ़लाइन जाँच)';

  @override
  String get docRc => 'RC बुक';

  @override
  String get docInsurance => 'बीमा';

  @override
  String get docNationalPermit => 'नेशनल परमिट';

  @override
  String get documentType => 'दस्तावेज़';

  @override
  String get docNumber => 'दस्तावेज़ नंबर';

  @override
  String get expiresOn => 'मान्य तिथि तक';

  @override
  String get chooseFile => 'फ़ाइल चुनें';

  @override
  String uploading(int percent) {
    return 'अपलोड हो रहा है… $percent%';
  }

  @override
  String fileChosen(int count) {
    return '$count फ़ाइल चुनी गई';
  }

  @override
  String get docPending => 'जाँच बाकी';

  @override
  String get docApproved => 'स्वीकृत';

  @override
  String get docRejected => 'अस्वीकृत';

  @override
  String rejectedReason(String reason) {
    return 'कारण: $reason';
  }

  @override
  String expiresOnDate(String date) {
    return '$date तक मान्य';
  }

  @override
  String get addDocument => 'दस्तावेज़ जोड़ें';

  @override
  String get completeVerificationTitle => 'सत्यापन पूरा करें';

  @override
  String get completeVerificationBody =>
      'यह करने के लिए सत्यापित खाता ज़रूरी है। अपनी प्रोफ़ाइल पूरी करें और सत्यापन के लिए भेजें।';

  @override
  String get goToProfile => 'प्रोफ़ाइल पर जाएँ';

  @override
  String get accountType => 'खाते का प्रकार';

  @override
  String get individual => 'व्यक्तिगत';

  @override
  String get business => 'व्यवसाय';

  @override
  String get businessName => 'व्यवसाय का नाम';

  @override
  String get businessNameOptional => 'व्यवसाय का नाम (वैकल्पिक)';

  @override
  String get gstinOptional => 'GSTIN (वैकल्पिक)';

  @override
  String get panOptional => 'PAN (वैकल्पिक)';

  @override
  String get networkName => 'नेटवर्क का नाम';

  @override
  String get registrationNumber => 'पंजीकरण नंबर';

  @override
  String get idType => 'आईडी का प्रकार';

  @override
  String get idNumber => 'आईडी नंबर';

  @override
  String get contactPerson => 'संपर्क व्यक्ति';

  @override
  String get licenceNumber => 'लाइसेंस नंबर';

  @override
  String get licenceValidUntil => 'लाइसेंस कब तक मान्य';

  @override
  String get vehicleClasses => 'वाहन श्रेणियाँ (जैसे HGMV, LMV)';

  @override
  String get emergencyContact => 'आपातकालीन संपर्क (वैकल्पिक)';

  @override
  String get orgName => 'संगठन का नाम';

  @override
  String get pickDate => 'तारीख चुनें';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get support => 'सहायता';

  @override
  String get mobileChanged => 'मोबाइल नंबर बदल दिया गया';

  @override
  String postingChargeIs(int amount) {
    return 'पोस्टिंग शुल्क ₹$amount';
  }

  @override
  String tripChargeIs(int amount) {
    return 'यात्रा शुल्क ₹$amount';
  }

  @override
  String get lowBalanceWarning =>
      'बैलेंस कम है। इस्तेमाल जारी रखने के लिए टॉप अप करें।';

  @override
  String get topUp => 'टॉप अप';

  @override
  String get otherAmount => 'दूसरी राशि (₹)';

  @override
  String get amountInvalid => 'राशि डालें';

  @override
  String get transactions => 'लेन-देन';

  @override
  String get allTypes => 'सभी';

  @override
  String get txnTopup => 'टॉप अप';

  @override
  String get txnPostingCharge => 'पोस्टिंग शुल्क';

  @override
  String get txnTripCharge => 'यात्रा शुल्क';

  @override
  String get txnRefund => 'रिफ़ंड';

  @override
  String get txnAdminCredit => 'ट्रानिक्स क्रेडिट';

  @override
  String get month => 'महीना';

  @override
  String get downloadStatement => 'स्टेटमेंट डाउनलोड करें';

  @override
  String get statementSaved => 'स्टेटमेंट सेव हो गया';

  @override
  String get noTransactions => 'अभी कोई लेन-देन नहीं';

  @override
  String get openingPayment => 'ब्राउज़र में भुगतान पूरा करें, फिर वापस आएँ।';

  @override
  String get tabTrips => 'यात्राएँ';

  @override
  String get tabWallet => 'वॉलेट';

  @override
  String get tabTranix => 'ट्रानिक्स';

  @override
  String get tabAccount => 'खाता';

  @override
  String get markAllRead => 'सभी पढ़ा हुआ करें';

  @override
  String get noNotifications => 'कोई सूचना नहीं';

  @override
  String get latestTranixMessage => 'ट्रानिक्स की ओर से';

  @override
  String get latestTripUpdate => 'ताज़ा यात्रा अपडेट';

  @override
  String get postLoad => 'लोड पोस्ट करें';

  @override
  String get pickupSection => 'पिकअप';

  @override
  String get goodsSection => 'माल';

  @override
  String get dropSection => 'ड्रॉप';

  @override
  String get receiverSection => 'प्राप्तकर्ता';

  @override
  String get paymentSection => 'भुगतान';

  @override
  String get offerTo => 'किसे ऑफ़र करें';

  @override
  String get pickupDate => 'पिकअप की तारीख';

  @override
  String get windowFrom => 'से';

  @override
  String get windowTo => 'तक';

  @override
  String get setLocation => 'स्थान चुनें';

  @override
  String get useCurrentLocation => 'मेरा मौजूदा स्थान इस्तेमाल करें';

  @override
  String get locationNotSet => 'स्थान नहीं चुना गया';

  @override
  String get addressLabel => 'पता';

  @override
  String get landmarkOptional => 'पहचान चिह्न (वैकल्पिक)';

  @override
  String get senderName => 'भेजने वाले का नाम';

  @override
  String get senderMobile => 'भेजने वाले का मोबाइल';

  @override
  String get goodsType => 'माल का प्रकार';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get quantity => 'मात्रा';

  @override
  String get unit => 'इकाई';

  @override
  String get weightTonnes => 'अनुमानित वज़न (टन)';

  @override
  String get vehicleType => 'वाहन का प्रकार';

  @override
  String get receiverName => 'प्राप्तकर्ता का नाम';

  @override
  String get receiverMobile => 'प्राप्तकर्ता का मोबाइल';

  @override
  String get freightPaidBy => 'भाड़ा कौन देगा';

  @override
  String get paidByMe => 'मैं';

  @override
  String get paidByReceiver => 'प्राप्तकर्ता';

  @override
  String get amountInr => 'राशि (₹)';

  @override
  String suggestedRange(String min, String max) {
    return 'मिलती-जुलती यात्राएँ: $min – $max';
  }

  @override
  String estimateLine(String km, String hours, String eta) {
    return '$km · $hours घंटे का सफ़र · $eta तक डिलीवरी';
  }

  @override
  String get offerEveryone => 'सभी को';

  @override
  String get offerWishlistFirst => 'पहले पसंदीदा सूची (15 मिनट, फिर सभी को)';

  @override
  String get offerWishlistOnly => 'सिर्फ़ पसंदीदा सूची';

  @override
  String get reviewTitle => 'जाँचें';

  @override
  String postingChargeNote(String amount) {
    return 'पोस्टिंग शुल्क $amount — सिर्फ़ ड्राइवर के स्वीकार करने पर कटेगा';
  }

  @override
  String get confirmPost => 'लोड पोस्ट करें';

  @override
  String get posted => 'लोड पोस्ट हो गया';

  @override
  String get saveChanges => 'बदलाव सेव करें';

  @override
  String topUpToPost(String amount) {
    return 'पोस्ट करने के लिए $amount टॉप अप करें';
  }

  @override
  String get editLoad => 'बदलें';

  @override
  String get cancelLoad => 'लोड रद्द करें';

  @override
  String get cancelReason => 'कारण';

  @override
  String get noteLabel => 'नोट';

  @override
  String get cancelOutcomeFree =>
      'कोई शुल्क नहीं। आपके ट्रस्ट स्कोर पर असर नहीं।';

  @override
  String cancelOutcomeKept(String points) {
    return 'शुल्क वापस नहीं होगा। दूसरे पक्ष की गलती न हो तो ट्रस्ट स्कोर $points।';
  }

  @override
  String get cancelSupportOnly =>
      'पिकअप के बाद रद्द करना सिर्फ़ सहायता के ज़रिए।';

  @override
  String get postAgain => 'फिर से पोस्ट करें';

  @override
  String get timeline => 'समयरेखा';

  @override
  String get deliveryEstimate => 'डिलीवरी का अनुमान';

  @override
  String get ongoingLoads => 'चालू लोड';

  @override
  String get noLoads => 'अभी कोई लोड नहीं';

  @override
  String get unitBags => 'बोरी';

  @override
  String get unitCrates => 'क्रेट';

  @override
  String get unitBoxes => 'डिब्बे';

  @override
  String get unitTonnes => 'टन';

  @override
  String get unitLitres => 'लीटर';

  @override
  String get vehOpenBody => 'ओपन बॉडी';

  @override
  String get vehClosedBody => 'क्लोज़्ड बॉडी';

  @override
  String get vehContainer => 'कंटेनर';

  @override
  String get vehRefrigerated => 'रेफ़्रिजरेटेड';

  @override
  String get vehTanker => 'टैंकर';

  @override
  String get vehAny => 'कोई भी';

  @override
  String get crPlansChanged => 'मेरी योजना बदल गई';

  @override
  String get crGoodsNotReady => 'माल तैयार नहीं';

  @override
  String get crFoundOtherTruck => 'दूसरा ट्रक मिल गया';

  @override
  String get crDriverNotReachable => 'ड्राइवर से संपर्क नहीं हो रहा';

  @override
  String get crDriverDidNotCome => 'ड्राइवर नहीं आया';

  @override
  String get crDriverAskedMore => 'ड्राइवर ने ज़्यादा पैसे माँगे';

  @override
  String get crTruckBreakdown => 'ट्रक खराब';

  @override
  String get crEmergency => 'आपातकाल';

  @override
  String get crShipperChangedDetails => 'भेजने वाले ने विवरण बदला';

  @override
  String get crAmountNotAgreed => 'राशि पर सहमति नहीं';

  @override
  String get crTooFar => 'बहुत दूर';

  @override
  String get crOther => 'अन्य';

  @override
  String get loadDetails => 'लोड का विवरण';

  @override
  String get sender => 'भेजने वाला';

  @override
  String get receiver => 'प्राप्तकर्ता';

  @override
  String get onDuty => 'ड्यूटी पर';

  @override
  String get offDuty => 'ड्यूटी से बाहर';

  @override
  String get goOnDutyHint => 'यात्रा सुझाव पाने के लिए ड्यूटी पर आएँ';

  @override
  String get myTruck => 'मेरा ट्रक';

  @override
  String get addTruck => 'मेरा ट्रक जोड़ें';

  @override
  String get truckNumber => 'ट्रक नंबर';

  @override
  String get capacityTonnes => 'क्षमता (टन)';

  @override
  String get truckAvailable => 'उपलब्ध';

  @override
  String get truckAllocated => 'आवंटित';

  @override
  String get truckOnTrip => 'यात्रा पर';

  @override
  String get truckDocumentsPending => 'दस्तावेज़ बाकी';

  @override
  String get truckInactive => 'निष्क्रिय';

  @override
  String get truckDocuments => 'ट्रक के दस्तावेज़';

  @override
  String invitationFrom(String org) {
    return '$org ने आपको ड्राइवर के रूप में बुलाया है';
  }

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get reject => 'अस्वीकार करें';

  @override
  String suggestionsAvailable(int count) {
    return '$count यात्रा सुझाव';
  }

  @override
  String get expiringDocs => 'जल्द समाप्त होने वाले दस्तावेज़';

  @override
  String get locker => 'दस्तावेज़ लॉकर';

  @override
  String truckAssignedBy(String org) {
    return '$org द्वारा दिया गया ट्रक';
  }

  @override
  String get openTrip => 'मौजूदा यात्रा खोलें';

  @override
  String get noTruckYet => 'अभी कोई ट्रक नहीं';

  @override
  String get invitations => 'संगठन के निमंत्रण';
}
