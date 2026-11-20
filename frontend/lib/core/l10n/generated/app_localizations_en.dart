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
}
