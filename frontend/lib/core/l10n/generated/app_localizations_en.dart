// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tranix';

  @override
  String get tagline => 'Verified road freight';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSignUp => 'Sign up';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionContinue => 'Continue';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateEmpty => 'Nothing here yet';

  @override
  String get stateOffline => 'You are offline. Some information may be old.';

  @override
  String get comingSoon => 'This screen is coming soon.';

  @override
  String get demoTitle => 'Demo (mock data)';

  @override
  String demoOpenAs(String role) {
    return 'Open as $role';
  }

  @override
  String get roleLoadProvider => 'Load Provider';

  @override
  String get roleFarmerNetwork => 'Farmer Network';

  @override
  String get roleDriver => 'Driver';

  @override
  String get roleOrganization => 'Organization';

  @override
  String get roleReceiver => 'Receiver';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get navHome => 'Home';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navHistory => 'History';

  @override
  String get navWishlist => 'Wish list';

  @override
  String get navProfile => 'Profile';

  @override
  String get navFarmers => 'Farmers';

  @override
  String get navSuggestions => 'Suggestions';

  @override
  String get navCurrentTrip => 'Current trip';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTrucks => 'Trucks';

  @override
  String get navDrivers => 'Drivers';

  @override
  String get navTrips => 'Trips';

  @override
  String get navLoads => 'Loads';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get loadStatusNotAccepted => 'Not accepted';

  @override
  String get loadStatusAccepted => 'Accepted';

  @override
  String get loadStatusAmountNegotiation => 'Amount request';

  @override
  String get loadStatusWaitingForPickup => 'Waiting for pickup';

  @override
  String get loadStatusLocationReached => 'Reached pickup';

  @override
  String get loadStatusPickedUp => 'Picked up';

  @override
  String get loadStatusTraveling => 'Traveling';

  @override
  String get loadStatusArrivedDestination => 'Arrived';

  @override
  String get loadStatusDelivered => 'Delivered';

  @override
  String get loadStatusCancelled => 'Cancelled';

  @override
  String get paymentStatusPending => 'Payment pending';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusConfirmed => 'Payment confirmed';

  @override
  String get paymentStatusDisputed => 'Disputed';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get walletBalance => 'Wallet balance';

  @override
  String get trustScore => 'Trust Score';

  @override
  String get verificationBanner => 'Complete verification to start';

  @override
  String get errorValidationFailed => 'Please check the highlighted fields.';

  @override
  String get errorUnauthenticated => 'Please sign in again.';

  @override
  String get errorTokenExpired => 'Your session expired. Please sign in again.';

  @override
  String get errorForbidden => 'You can\'t do this.';

  @override
  String get errorNotVerified => 'Complete verification to do this.';

  @override
  String get errorNotFound => 'We couldn\'t find this.';

  @override
  String get errorOtpInvalid => 'Wrong OTP. Please check and try again.';

  @override
  String get errorOtpExpired => 'This OTP has expired. Ask for a new one.';

  @override
  String get errorOtpLocked => 'Too many wrong tries. Try again in 15 minutes.';

  @override
  String get errorMobileInUse =>
      'This number already has an account. Please sign in.';

  @override
  String get errorInsufficientBalance =>
      'Your wallet balance is too low. Please top up.';

  @override
  String get errorLoadTaken => 'Taken by another driver.';

  @override
  String get errorInvalidState => 'This can\'t be done right now.';

  @override
  String get errorRevisionLimitReached =>
      'You have used all amount requests for this trip.';

  @override
  String get errorRevisionPending =>
      'An amount request is already waiting for an answer.';

  @override
  String get errorAllocationConflict =>
      'This driver or truck is already allocated.';

  @override
  String get errorWishlistFull => 'Your wish list is full.';

  @override
  String get errorWishlistEmpty =>
      'No one from your wish list can take this load. Offer it to everyone or change the selection.';

  @override
  String get errorRateLimited => 'Too many tries. Please wait a moment.';

  @override
  String get errorNetwork => 'No internet connection. Please try again.';

  @override
  String get errorTimeout => 'The server is taking too long. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get mobileLabel => 'Mobile number';

  @override
  String get mobileInvalid => 'Enter a valid 10-digit mobile number';

  @override
  String get nameLabel => 'Full name';

  @override
  String get nameInvalid => 'Name must be 2 to 60 characters';

  @override
  String get roleQuestion => 'I am a';

  @override
  String get roleRequired => 'Choose who you are';

  @override
  String get consentText => 'I agree to the Terms of Use and Privacy Policy';

  @override
  String get consentRequired => 'Please accept to continue';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpTitle => 'Enter OTP';

  @override
  String otpSentTo(String mobile) {
    return 'We sent a 6-digit code to +91 $mobile';
  }

  @override
  String resendIn(int seconds) {
    return 'Resend OTP in $seconds s';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verify => 'Verify';

  @override
  String get signInInstead => 'Sign in instead';

  @override
  String get noAccount => 'New to Tranix? Sign up';

  @override
  String get completeProfileBanner => 'Complete your profile to start';

  @override
  String get otpSent => 'OTP sent';

  @override
  String get photo => 'Photo';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get pdfFile => 'PDF file';

  @override
  String get basicDetails => 'Name, email and address';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get address => 'Address';

  @override
  String get addressLine => 'House / street';

  @override
  String get village => 'Village / town';

  @override
  String get district => 'District';

  @override
  String get state => 'State';

  @override
  String get pinCode => 'PIN code';

  @override
  String get pinInvalid => 'Enter a 6-digit PIN code';

  @override
  String get fieldRequired => 'Required';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get language => 'Language';

  @override
  String get roleDetails => 'Account details';

  @override
  String get idProof => 'ID proof';

  @override
  String get documents => 'Documents';

  @override
  String get changeMobile => 'Change mobile number';

  @override
  String get newMobile => 'New mobile number';

  @override
  String get verificationTitle => 'Verification';

  @override
  String get submitForVerification => 'Submit for verification';

  @override
  String get statusNotSubmitted => 'Not submitted';

  @override
  String get statusUnderReview => 'Under review';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusNotVerified => 'Not verified';

  @override
  String underReviewInfo(int hours) {
    return 'We are checking your details. This usually takes about $hours hours.';
  }

  @override
  String get notVerifiedInfo => 'Some documents need to be uploaded again.';

  @override
  String get verifiedInfo => 'You are verified. You can now use all features.';

  @override
  String get notSubmittedInfo =>
      'Complete every item below, then submit for verification.';

  @override
  String get checkUpdates => 'Check updates';

  @override
  String get uploadAgain => 'Upload again';

  @override
  String get docPan => 'PAN card';

  @override
  String get docVoterId => 'Voter ID';

  @override
  String get docDrivingLicence => 'Driving licence';

  @override
  String get docPhoto => 'Photo';

  @override
  String get docFnRegistrationCert => 'Registration certificate';

  @override
  String get docOrgRegistrationCert => 'Registration certificate';

  @override
  String get docGstCert => 'GST certificate';

  @override
  String get docAadhaar => 'Aadhaar (offline check)';

  @override
  String get docRc => 'RC book';

  @override
  String get docInsurance => 'Insurance';

  @override
  String get docNationalPermit => 'National permit';

  @override
  String get documentType => 'Document';

  @override
  String get docNumber => 'Document number';

  @override
  String get expiresOn => 'Valid until';

  @override
  String get chooseFile => 'Choose file';

  @override
  String uploading(int percent) {
    return 'Uploading… $percent%';
  }

  @override
  String fileChosen(int count) {
    return '$count file(s) chosen';
  }

  @override
  String get docPending => 'Pending review';

  @override
  String get docApproved => 'Approved';

  @override
  String get docRejected => 'Rejected';

  @override
  String rejectedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String expiresOnDate(String date) {
    return 'Valid until $date';
  }

  @override
  String get addDocument => 'Add document';

  @override
  String get completeVerificationTitle => 'Complete verification';

  @override
  String get completeVerificationBody =>
      'You need a verified account to do this. Complete your profile and submit it for verification.';

  @override
  String get goToProfile => 'Go to profile';

  @override
  String get accountType => 'Account type';

  @override
  String get individual => 'Individual';

  @override
  String get business => 'Business';

  @override
  String get businessName => 'Business name';

  @override
  String get businessNameOptional => 'Business name (optional)';

  @override
  String get gstinOptional => 'GSTIN (optional)';

  @override
  String get panOptional => 'PAN (optional)';

  @override
  String get networkName => 'Network name';

  @override
  String get registrationNumber => 'Registration number';

  @override
  String get idType => 'ID type';

  @override
  String get idNumber => 'ID number';

  @override
  String get contactPerson => 'Contact person';

  @override
  String get licenceNumber => 'Licence number';

  @override
  String get licenceValidUntil => 'Licence valid until';

  @override
  String get vehicleClasses => 'Vehicle classes (e.g. HGMV, LMV)';

  @override
  String get emergencyContact => 'Emergency contact (optional)';

  @override
  String get orgName => 'Organization name';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get wallet => 'Wallet';

  @override
  String get support => 'Support';

  @override
  String get mobileChanged => 'Mobile number changed';

  @override
  String postingChargeIs(int amount) {
    return 'Posting charge ₹$amount';
  }

  @override
  String tripChargeIs(int amount) {
    return 'Trip charge ₹$amount';
  }

  @override
  String get lowBalanceWarning => 'Low balance. Top up to keep using Tranix.';

  @override
  String get topUp => 'Top up';

  @override
  String get otherAmount => 'Other amount (₹)';

  @override
  String get amountInvalid => 'Enter an amount';

  @override
  String get transactions => 'Transactions';

  @override
  String get allTypes => 'All';

  @override
  String get txnTopup => 'Top-up';

  @override
  String get txnPostingCharge => 'Posting charge';

  @override
  String get txnTripCharge => 'Trip charge';

  @override
  String get txnRefund => 'Refund';

  @override
  String get txnAdminCredit => 'Tranix credit';

  @override
  String get month => 'Month';

  @override
  String get downloadStatement => 'Download statement';

  @override
  String get statementSaved => 'Statement saved';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get openingPayment =>
      'Complete the payment in your browser, then come back.';

  @override
  String get tabTrips => 'Trips';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get tabTranix => 'Tranix';

  @override
  String get tabAccount => 'Account';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get latestTranixMessage => 'From Tranix';

  @override
  String get latestTripUpdate => 'Latest trip update';

  @override
  String get postLoad => 'Post a load';

  @override
  String get pickupSection => 'Pickup';

  @override
  String get goodsSection => 'Goods';

  @override
  String get dropSection => 'Drop';

  @override
  String get receiverSection => 'Receiver';

  @override
  String get paymentSection => 'Payment';

  @override
  String get offerTo => 'Offer to';

  @override
  String get pickupDate => 'Pickup date';

  @override
  String get windowFrom => 'From';

  @override
  String get windowTo => 'To';

  @override
  String get setLocation => 'Set location';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get locationNotSet => 'Location not set';

  @override
  String get addressLabel => 'Address';

  @override
  String get landmarkOptional => 'Landmark (optional)';

  @override
  String get senderName => 'Sender name';

  @override
  String get senderMobile => 'Sender mobile';

  @override
  String get goodsType => 'Goods type';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get weightTonnes => 'Approx. weight (tonnes)';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get receiverName => 'Receiver name';

  @override
  String get receiverMobile => 'Receiver mobile';

  @override
  String get freightPaidBy => 'Freight paid by';

  @override
  String get paidByMe => 'Me';

  @override
  String get paidByReceiver => 'Receiver';

  @override
  String get amountInr => 'Amount (₹)';

  @override
  String suggestedRange(String min, String max) {
    return 'Similar trips: $min – $max';
  }

  @override
  String estimateLine(String km, String hours, String eta) {
    return '$km · $hours h drive · Delivery by $eta';
  }

  @override
  String get offerEveryone => 'Everyone';

  @override
  String get offerWishlistFirst => 'Wish list first (15 min, then everyone)';

  @override
  String get offerWishlistOnly => 'Wish list only';

  @override
  String get reviewTitle => 'Review';

  @override
  String postingChargeNote(String amount) {
    return 'Posting charge $amount — charged only when a driver accepts';
  }

  @override
  String get confirmPost => 'Post load';

  @override
  String get posted => 'Load posted';

  @override
  String get saveChanges => 'Save changes';

  @override
  String topUpToPost(String amount) {
    return 'Top up $amount to post';
  }

  @override
  String get editLoad => 'Edit';

  @override
  String get cancelLoad => 'Cancel load';

  @override
  String get cancelReason => 'Reason';

  @override
  String get noteLabel => 'Note';

  @override
  String get cancelOutcomeFree =>
      'No charges. Your Trust Score is not affected.';

  @override
  String cancelOutcomeKept(String points) {
    return 'Charges are kept. Trust Score $points unless the other party was at fault.';
  }

  @override
  String get cancelSupportOnly => 'After pickup, cancel only through Support.';

  @override
  String get postAgain => 'Post again';

  @override
  String get timeline => 'Timeline';

  @override
  String get deliveryEstimate => 'Delivery estimate';

  @override
  String get ongoingLoads => 'Ongoing loads';

  @override
  String get noLoads => 'No loads yet';

  @override
  String get unitBags => 'Bags';

  @override
  String get unitCrates => 'Crates';

  @override
  String get unitBoxes => 'Boxes';

  @override
  String get unitTonnes => 'Tonnes';

  @override
  String get unitLitres => 'Litres';

  @override
  String get vehOpenBody => 'Open body';

  @override
  String get vehClosedBody => 'Closed body';

  @override
  String get vehContainer => 'Container';

  @override
  String get vehRefrigerated => 'Refrigerated';

  @override
  String get vehTanker => 'Tanker';

  @override
  String get vehAny => 'Any';

  @override
  String get crPlansChanged => 'My plans changed';

  @override
  String get crGoodsNotReady => 'Goods not ready';

  @override
  String get crFoundOtherTruck => 'Found another truck';

  @override
  String get crDriverNotReachable => 'Driver not reachable';

  @override
  String get crDriverDidNotCome => 'Driver did not come';

  @override
  String get crDriverAskedMore => 'Driver asked for more money';

  @override
  String get crTruckBreakdown => 'Truck breakdown';

  @override
  String get crEmergency => 'Emergency';

  @override
  String get crShipperChangedDetails => 'Shipper changed the details';

  @override
  String get crAmountNotAgreed => 'Amount not agreed';

  @override
  String get crTooFar => 'Too far';

  @override
  String get crOther => 'Other';

  @override
  String get loadDetails => 'Load details';

  @override
  String get sender => 'Sender';

  @override
  String get receiver => 'Receiver';

  @override
  String get onDuty => 'On duty';

  @override
  String get offDuty => 'Off duty';

  @override
  String get goOnDutyHint => 'Go on duty to get trip suggestions';

  @override
  String get myTruck => 'My truck';

  @override
  String get addTruck => 'Add my truck';

  @override
  String get truckNumber => 'Truck number';

  @override
  String get capacityTonnes => 'Capacity (tonnes)';

  @override
  String get truckAvailable => 'Available';

  @override
  String get truckAllocated => 'Allocated';

  @override
  String get truckOnTrip => 'On trip';

  @override
  String get truckDocumentsPending => 'Documents pending';

  @override
  String get truckInactive => 'Inactive';

  @override
  String get truckDocuments => 'Truck documents';

  @override
  String invitationFrom(String org) {
    return '$org invited you to drive for them';
  }

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String suggestionsAvailable(int count) {
    return '$count trip suggestions';
  }

  @override
  String get expiringDocs => 'Documents expiring soon';

  @override
  String get locker => 'Document locker';

  @override
  String truckAssignedBy(String org) {
    return 'Truck assigned by $org';
  }

  @override
  String get openTrip => 'Open current trip';

  @override
  String get noTruckYet => 'No truck yet';

  @override
  String get invitations => 'Organization invitations';

  @override
  String get sortNearest => 'Nearest';

  @override
  String get sortAmount => 'Amount';

  @override
  String get sortEarliest => 'Earliest';

  @override
  String get acceptTrip => 'Accept';

  @override
  String get acceptConfirmTitle => 'Accept this trip?';

  @override
  String acceptConfirmBody(String amount, String charge) {
    return 'Amount $amount. Trip charge $charge is deducted now.';
  }

  @override
  String get rejectTrip => 'Not interested';

  @override
  String get rejectWhy => 'Why not?';

  @override
  String get rrTooFar => 'Too far';

  @override
  String get rrLowAmount => 'Amount too low';

  @override
  String get rrWrongTruck => 'Wrong truck';

  @override
  String get preferredTag => 'Preferred by this shipper';

  @override
  String toPickup(String km, int minutes) {
    return '$km away · $minutes min to pickup';
  }

  @override
  String get topUpToSeeTrips => 'Top up to see trips';

  @override
  String get noSuggestions =>
      'No trips right now. New ones arrive every few minutes.';

  @override
  String get driverSection => 'Driver';

  @override
  String get callAction => 'Call';

  @override
  String get tripAccepted => 'Trip accepted';

  @override
  String get stepReachedPickup => 'Reached pickup';

  @override
  String get stepEnterPickupOtp => 'Enter pickup OTP';

  @override
  String get stepReachedDrop => 'Reached destination';

  @override
  String get stepEnterDeliveryOtp => 'Enter delivery OTP';

  @override
  String get navigate => 'Navigate';

  @override
  String get requestAmount => 'Request new amount';

  @override
  String amountUsed(int used, int limit) {
    return '$used of $limit used';
  }

  @override
  String get amountPendingWait => 'Waiting for the shipper\'s answer';

  @override
  String get newAmount => 'New amount (₹)';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get sendAction => 'Send';

  @override
  String get cancelTrip => 'Cancel trip';

  @override
  String outsideRadiusTitle(int meters) {
    return 'You are $meters m from the pin';
  }

  @override
  String get outsideRadiusBody => 'Tell us why you are not at the pin.';

  @override
  String get otpAskSender => 'Ask the sender for the 6-digit code';

  @override
  String get otpAskReceiver => 'Ask the receiver for the 6-digit code';

  @override
  String otpSentToMobile(String mobile) {
    return 'Sent to $mobile';
  }

  @override
  String get cantGetOtp => 'Can\'t get OTP?';

  @override
  String get helpNote => 'What happened?';

  @override
  String get helpSent => 'Help request sent. Tranix will call you.';

  @override
  String get noActiveTrip => 'No active trip. Accept a suggestion to start.';

  @override
  String get locationExplainTitle => 'Share your location during trips';

  @override
  String get locationExplainBody =>
      'Tranix uses your location only during an active trip, so the shipper and receiver can see the truck. A notification shows while it is on.';

  @override
  String get allow => 'Allow';

  @override
  String tripInProgress(String code) {
    return 'Tranix trip $code in progress';
  }

  @override
  String get layerPetrol => 'Petrol';

  @override
  String get layerWeighbridge => 'Weighbridge';

  @override
  String get layerPuncture => 'Puncture';

  @override
  String get layerToll => 'Toll';

  @override
  String get layerRestrictions => 'Restrictions';

  @override
  String noEntryHours(String from, String to) {
    return 'No entry $from–$to';
  }

  @override
  String get amountRequestTitle => 'Amount request';

  @override
  String amountRequestBody(String amount, String reason) {
    return 'Driver asks $amount: $reason';
  }

  @override
  String answerBy(String time) {
    return 'Answer by $time';
  }

  @override
  String get rejectKeepsAmount =>
      'Rejecting keeps the current amount; the trip continues.';

  @override
  String get pickupOtpTitle => 'Pickup OTP';

  @override
  String get deliveryOtpTitle => 'Delivery OTP';

  @override
  String get shareAfterLoading =>
      'Share this code with the driver after loading.';

  @override
  String get shareAfterChecking => 'Share only after checking the goods.';

  @override
  String get liveTracking => 'Live tracking';

  @override
  String lastSeen(String time) {
    return 'Truck seen $time';
  }

  @override
  String get routeNormal => 'On time';

  @override
  String get routeSlow => 'Running slow';

  @override
  String get routeFast => 'Running fast';

  @override
  String etaAt(String time) {
    return 'ETA $time';
  }

  @override
  String get pickupAt => 'Pickup';

  @override
  String get dropAt => 'Drop';

  @override
  String get callSender => 'Call sender';

  @override
  String get callReceiver => 'Call receiver';

  @override
  String get callShipper => 'Call shipper';

  @override
  String get markPaid => 'Mark as paid';

  @override
  String get paymentMode => 'Mode';

  @override
  String get modeCash => 'Cash';

  @override
  String get modeUpi => 'UPI';

  @override
  String get modeBank => 'Bank';

  @override
  String get referenceOptional => 'Reference (optional)';

  @override
  String get confirmReceived => 'Confirm received';

  @override
  String get disputePayment => 'Dispute';

  @override
  String get disputeReason => 'What is wrong?';

  @override
  String paidVia(String amount, String mode) {
    return '$amount by $mode';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String tripsCount(int count) {
    return '$count trips';
  }

  @override
  String get agreedTotal => 'Agreed';

  @override
  String get receivedTotal => 'Received';

  @override
  String get pendingTotal => 'Pending';

  @override
  String rateTitle(String name) {
    return 'Rate $name';
  }

  @override
  String get rateLater => 'Later';

  @override
  String get submitAction => 'Submit';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get howItWorks => 'How it works';

  @override
  String get trustHowBody =>
      'Your score starts at 70 (out of 100). On-time trips, good ratings and on-time payments raise it; late trips, cancellations after acceptance and lost disputes lower it.';

  @override
  String get noEvents => 'No changes yet';

  @override
  String get evOnTime => 'Trip on time';

  @override
  String get evLateDelivery => 'Late delivery';

  @override
  String get evLatePickup => 'Late pickup';

  @override
  String get evCancelled => 'Cancelled after acceptance';

  @override
  String get evRating => 'Rating received';

  @override
  String get evPaymentOnTime => 'Payment on time';

  @override
  String get evDisputeLost => 'Dispute lost';

  @override
  String get evAdmin => 'Adjusted by Tranix';

  @override
  String get evComplaint => 'Verified complaint';

  @override
  String get evDriverCancelled => 'Driver cancelled';
}
