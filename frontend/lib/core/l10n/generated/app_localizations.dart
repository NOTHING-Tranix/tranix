import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tranix'**
  String get appTitle;

  /// Short line under the logo on the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Verified road freight'**
  String get tagline;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get actionSignUp;

  /// No description provided for @actionSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get actionSignIn;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmpty;

  /// No description provided for @stateOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some information may be old.'**
  String get stateOffline;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This screen is coming soon.'**
  String get comingSoon;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo (mock data)'**
  String get demoTitle;

  /// No description provided for @demoOpenAs.
  ///
  /// In en, this message translates to:
  /// **'Open as {role}'**
  String demoOpenAs(String role);

  /// No description provided for @roleLoadProvider.
  ///
  /// In en, this message translates to:
  /// **'Load Provider'**
  String get roleLoadProvider;

  /// No description provided for @roleFarmerNetwork.
  ///
  /// In en, this message translates to:
  /// **'Farmer Network'**
  String get roleFarmerNetwork;

  /// No description provided for @roleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get roleDriver;

  /// No description provided for @roleOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get roleOrganization;

  /// No description provided for @roleReceiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get roleReceiver;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wish list'**
  String get navWishlist;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navFarmers.
  ///
  /// In en, this message translates to:
  /// **'Farmers'**
  String get navFarmers;

  /// No description provided for @navSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get navSuggestions;

  /// No description provided for @navCurrentTrip.
  ///
  /// In en, this message translates to:
  /// **'Current trip'**
  String get navCurrentTrip;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navTrucks.
  ///
  /// In en, this message translates to:
  /// **'Trucks'**
  String get navTrucks;

  /// No description provided for @navDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get navDrivers;

  /// No description provided for @navTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// No description provided for @navLoads.
  ///
  /// In en, this message translates to:
  /// **'Loads'**
  String get navLoads;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @loadStatusNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get loadStatusNotAccepted;

  /// No description provided for @loadStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get loadStatusAccepted;

  /// No description provided for @loadStatusAmountNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Amount request'**
  String get loadStatusAmountNegotiation;

  /// No description provided for @loadStatusWaitingForPickup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get loadStatusWaitingForPickup;

  /// No description provided for @loadStatusLocationReached.
  ///
  /// In en, this message translates to:
  /// **'Reached pickup'**
  String get loadStatusLocationReached;

  /// No description provided for @loadStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get loadStatusPickedUp;

  /// No description provided for @loadStatusTraveling.
  ///
  /// In en, this message translates to:
  /// **'Traveling'**
  String get loadStatusTraveling;

  /// No description provided for @loadStatusArrivedDestination.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get loadStatusArrivedDestination;

  /// No description provided for @loadStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get loadStatusDelivered;

  /// No description provided for @loadStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get loadStatusCancelled;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get paymentStatusConfirmed;

  /// No description provided for @paymentStatusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get paymentStatusDisputed;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalance;

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get trustScore;

  /// No description provided for @verificationBanner.
  ///
  /// In en, this message translates to:
  /// **'Complete verification to start'**
  String get verificationBanner;

  /// No description provided for @errorValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get errorValidationFailed;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get errorUnauthenticated;

  /// No description provided for @errorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorTokenExpired;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You can\'t do this.'**
  String get errorForbidden;

  /// No description provided for @errorNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Complete verification to do this.'**
  String get errorNotVerified;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this.'**
  String get errorNotFound;

  /// No description provided for @errorOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Wrong OTP. Please check and try again.'**
  String get errorOtpInvalid;

  /// No description provided for @errorOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'This OTP has expired. Ask for a new one.'**
  String get errorOtpExpired;

  /// No description provided for @errorOtpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong tries. Try again in 15 minutes.'**
  String get errorOtpLocked;

  /// No description provided for @errorMobileInUse.
  ///
  /// In en, this message translates to:
  /// **'This number already has an account. Please sign in.'**
  String get errorMobileInUse;

  /// No description provided for @errorInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance is too low. Please top up.'**
  String get errorInsufficientBalance;

  /// No description provided for @errorLoadTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken by another driver.'**
  String get errorLoadTaken;

  /// No description provided for @errorInvalidState.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be done right now.'**
  String get errorInvalidState;

  /// No description provided for @errorRevisionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have used all amount requests for this trip.'**
  String get errorRevisionLimitReached;

  /// No description provided for @errorRevisionPending.
  ///
  /// In en, this message translates to:
  /// **'An amount request is already waiting for an answer.'**
  String get errorRevisionPending;

  /// No description provided for @errorAllocationConflict.
  ///
  /// In en, this message translates to:
  /// **'This driver or truck is already allocated.'**
  String get errorAllocationConflict;

  /// No description provided for @errorWishlistFull.
  ///
  /// In en, this message translates to:
  /// **'Your wish list is full.'**
  String get errorWishlistFull;

  /// No description provided for @errorWishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one from your wish list can take this load. Offer it to everyone or change the selection.'**
  String get errorWishlistEmpty;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a moment.'**
  String get errorRateLimited;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @mobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileLabel;

  /// No description provided for @mobileInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get mobileInvalid;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameLabel;

  /// No description provided for @nameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Name must be 2 to 60 characters'**
  String get nameInvalid;

  /// No description provided for @roleQuestion.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get roleQuestion;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose who you are'**
  String get roleRequired;

  /// No description provided for @consentText.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Use and Privacy Policy'**
  String get consentText;

  /// No description provided for @consentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept to continue'**
  String get consentRequired;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to +91 {mobile}'**
  String otpSentTo(String mobile);

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds} s'**
  String resendIn(int seconds);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @signInInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in instead'**
  String get signInInstead;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Tranix? Sign up'**
  String get noAccount;

  /// No description provided for @completeProfileBanner.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to start'**
  String get completeProfileBanner;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent'**
  String get otpSent;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @pdfFile.
  ///
  /// In en, this message translates to:
  /// **'PDF file'**
  String get pdfFile;

  /// No description provided for @basicDetails.
  ///
  /// In en, this message translates to:
  /// **'Name, email and address'**
  String get basicDetails;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'House / street'**
  String get addressLine;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village / town'**
  String get village;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinCode;

  /// No description provided for @pinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit PIN code'**
  String get pinInvalid;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @roleDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get roleDetails;

  /// No description provided for @idProof.
  ///
  /// In en, this message translates to:
  /// **'ID proof'**
  String get idProof;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @changeMobile.
  ///
  /// In en, this message translates to:
  /// **'Change mobile number'**
  String get changeMobile;

  /// No description provided for @newMobile.
  ///
  /// In en, this message translates to:
  /// **'New mobile number'**
  String get newMobile;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get submitForVerification;

  /// No description provided for @statusNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get statusNotSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusUnderReview;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get statusNotVerified;

  /// No description provided for @underReviewInfo.
  ///
  /// In en, this message translates to:
  /// **'We are checking your details. This usually takes about {hours} hours.'**
  String underReviewInfo(int hours);

  /// No description provided for @notVerifiedInfo.
  ///
  /// In en, this message translates to:
  /// **'Some documents need to be uploaded again.'**
  String get notVerifiedInfo;

  /// No description provided for @verifiedInfo.
  ///
  /// In en, this message translates to:
  /// **'You are verified. You can now use all features.'**
  String get verifiedInfo;

  /// No description provided for @notSubmittedInfo.
  ///
  /// In en, this message translates to:
  /// **'Complete every item below, then submit for verification.'**
  String get notSubmittedInfo;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check updates'**
  String get checkUpdates;

  /// No description provided for @uploadAgain.
  ///
  /// In en, this message translates to:
  /// **'Upload again'**
  String get uploadAgain;

  /// No description provided for @docPan.
  ///
  /// In en, this message translates to:
  /// **'PAN card'**
  String get docPan;

  /// No description provided for @docVoterId.
  ///
  /// In en, this message translates to:
  /// **'Voter ID'**
  String get docVoterId;

  /// No description provided for @docDrivingLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get docDrivingLicence;

  /// No description provided for @docPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get docPhoto;

  /// No description provided for @docFnRegistrationCert.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate'**
  String get docFnRegistrationCert;

  /// No description provided for @docOrgRegistrationCert.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate'**
  String get docOrgRegistrationCert;

  /// No description provided for @docGstCert.
  ///
  /// In en, this message translates to:
  /// **'GST certificate'**
  String get docGstCert;

  /// No description provided for @docAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar (offline check)'**
  String get docAadhaar;

  /// No description provided for @docRc.
  ///
  /// In en, this message translates to:
  /// **'RC book'**
  String get docRc;

  /// No description provided for @docInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get docInsurance;

  /// No description provided for @docNationalPermit.
  ///
  /// In en, this message translates to:
  /// **'National permit'**
  String get docNationalPermit;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentType;

  /// No description provided for @docNumber.
  ///
  /// In en, this message translates to:
  /// **'Document number'**
  String get docNumber;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get expiresOn;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String uploading(int percent);

  /// No description provided for @fileChosen.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) chosen'**
  String fileChosen(int count);

  /// No description provided for @docPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get docPending;

  /// No description provided for @docApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get docApproved;

  /// No description provided for @docRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get docRejected;

  /// No description provided for @rejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String rejectedReason(String reason);

  /// No description provided for @expiresOnDate.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String expiresOnDate(String date);

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocument;

  /// No description provided for @completeVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete verification'**
  String get completeVerificationTitle;

  /// No description provided for @completeVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'You need a verified account to do this. Complete your profile and submit it for verification.'**
  String get completeVerificationBody;

  /// No description provided for @goToProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to profile'**
  String get goToProfile;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @businessNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Business name (optional)'**
  String get businessNameOptional;

  /// No description provided for @gstinOptional.
  ///
  /// In en, this message translates to:
  /// **'GSTIN (optional)'**
  String get gstinOptional;

  /// No description provided for @panOptional.
  ///
  /// In en, this message translates to:
  /// **'PAN (optional)'**
  String get panOptional;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Network name'**
  String get networkName;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get registrationNumber;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID type'**
  String get idType;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get idNumber;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get contactPerson;

  /// No description provided for @licenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Licence number'**
  String get licenceNumber;

  /// No description provided for @licenceValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Licence valid until'**
  String get licenceValidUntil;

  /// No description provided for @vehicleClasses.
  ///
  /// In en, this message translates to:
  /// **'Vehicle classes (e.g. HGMV, LMV)'**
  String get vehicleClasses;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact (optional)'**
  String get emergencyContact;

  /// No description provided for @orgName.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get orgName;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @mobileChanged.
  ///
  /// In en, this message translates to:
  /// **'Mobile number changed'**
  String get mobileChanged;

  /// No description provided for @postingChargeIs.
  ///
  /// In en, this message translates to:
  /// **'Posting charge ₹{amount}'**
  String postingChargeIs(int amount);

  /// No description provided for @tripChargeIs.
  ///
  /// In en, this message translates to:
  /// **'Trip charge ₹{amount}'**
  String tripChargeIs(int amount);

  /// No description provided for @lowBalanceWarning.
  ///
  /// In en, this message translates to:
  /// **'Low balance. Top up to keep using Tranix.'**
  String get lowBalanceWarning;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @otherAmount.
  ///
  /// In en, this message translates to:
  /// **'Other amount (₹)'**
  String get otherAmount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get amountInvalid;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTypes;

  /// No description provided for @txnTopup.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get txnTopup;

  /// No description provided for @txnPostingCharge.
  ///
  /// In en, this message translates to:
  /// **'Posting charge'**
  String get txnPostingCharge;

  /// No description provided for @txnTripCharge.
  ///
  /// In en, this message translates to:
  /// **'Trip charge'**
  String get txnTripCharge;

  /// No description provided for @txnRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get txnRefund;

  /// No description provided for @txnAdminCredit.
  ///
  /// In en, this message translates to:
  /// **'Tranix credit'**
  String get txnAdminCredit;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @downloadStatement.
  ///
  /// In en, this message translates to:
  /// **'Download statement'**
  String get downloadStatement;

  /// No description provided for @statementSaved.
  ///
  /// In en, this message translates to:
  /// **'Statement saved'**
  String get statementSaved;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @openingPayment.
  ///
  /// In en, this message translates to:
  /// **'Complete the payment in your browser, then come back.'**
  String get openingPayment;

  /// No description provided for @tabTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tabTrips;

  /// No description provided for @tabWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get tabWallet;

  /// No description provided for @tabTranix.
  ///
  /// In en, this message translates to:
  /// **'Tranix'**
  String get tabTranix;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @latestTranixMessage.
  ///
  /// In en, this message translates to:
  /// **'From Tranix'**
  String get latestTranixMessage;

  /// No description provided for @latestTripUpdate.
  ///
  /// In en, this message translates to:
  /// **'Latest trip update'**
  String get latestTripUpdate;

  /// No description provided for @postLoad.
  ///
  /// In en, this message translates to:
  /// **'Post a load'**
  String get postLoad;

  /// No description provided for @pickupSection.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupSection;

  /// No description provided for @goodsSection.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get goodsSection;

  /// No description provided for @dropSection.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get dropSection;

  /// No description provided for @receiverSection.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiverSection;

  /// No description provided for @paymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentSection;

  /// No description provided for @offerTo.
  ///
  /// In en, this message translates to:
  /// **'Offer to'**
  String get offerTo;

  /// No description provided for @pickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup date'**
  String get pickupDate;

  /// No description provided for @windowFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get windowFrom;

  /// No description provided for @windowTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get windowTo;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get setLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useCurrentLocation;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get locationNotSet;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @landmarkOptional.
  ///
  /// In en, this message translates to:
  /// **'Landmark (optional)'**
  String get landmarkOptional;

  /// No description provided for @senderName.
  ///
  /// In en, this message translates to:
  /// **'Sender name'**
  String get senderName;

  /// No description provided for @senderMobile.
  ///
  /// In en, this message translates to:
  /// **'Sender mobile'**
  String get senderMobile;

  /// No description provided for @goodsType.
  ///
  /// In en, this message translates to:
  /// **'Goods type'**
  String get goodsType;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @weightTonnes.
  ///
  /// In en, this message translates to:
  /// **'Approx. weight (tonnes)'**
  String get weightTonnes;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleType;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get receiverName;

  /// No description provided for @receiverMobile.
  ///
  /// In en, this message translates to:
  /// **'Receiver mobile'**
  String get receiverMobile;

  /// No description provided for @freightPaidBy.
  ///
  /// In en, this message translates to:
  /// **'Freight paid by'**
  String get freightPaidBy;

  /// No description provided for @paidByMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get paidByMe;

  /// No description provided for @paidByReceiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get paidByReceiver;

  /// No description provided for @amountInr.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amountInr;

  /// No description provided for @suggestedRange.
  ///
  /// In en, this message translates to:
  /// **'Similar trips: {min} – {max}'**
  String suggestedRange(String min, String max);

  /// No description provided for @estimateLine.
  ///
  /// In en, this message translates to:
  /// **'{km} · {hours} h drive · Delivery by {eta}'**
  String estimateLine(String km, String hours, String eta);

  /// No description provided for @offerEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get offerEveryone;

  /// No description provided for @offerWishlistFirst.
  ///
  /// In en, this message translates to:
  /// **'Wish list first (15 min, then everyone)'**
  String get offerWishlistFirst;

  /// No description provided for @offerWishlistOnly.
  ///
  /// In en, this message translates to:
  /// **'Wish list only'**
  String get offerWishlistOnly;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @postingChargeNote.
  ///
  /// In en, this message translates to:
  /// **'Posting charge {amount} — charged only when a driver accepts'**
  String postingChargeNote(String amount);

  /// No description provided for @confirmPost.
  ///
  /// In en, this message translates to:
  /// **'Post load'**
  String get confirmPost;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Load posted'**
  String get posted;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @topUpToPost.
  ///
  /// In en, this message translates to:
  /// **'Top up {amount} to post'**
  String topUpToPost(String amount);

  /// No description provided for @editLoad.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLoad;

  /// No description provided for @cancelLoad.
  ///
  /// In en, this message translates to:
  /// **'Cancel load'**
  String get cancelLoad;

  /// No description provided for @cancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get cancelReason;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @cancelOutcomeFree.
  ///
  /// In en, this message translates to:
  /// **'No charges. Your Trust Score is not affected.'**
  String get cancelOutcomeFree;

  /// No description provided for @cancelOutcomeKept.
  ///
  /// In en, this message translates to:
  /// **'Charges are kept. Trust Score {points} unless the other party was at fault.'**
  String cancelOutcomeKept(String points);

  /// No description provided for @cancelSupportOnly.
  ///
  /// In en, this message translates to:
  /// **'After pickup, cancel only through Support.'**
  String get cancelSupportOnly;

  /// No description provided for @postAgain.
  ///
  /// In en, this message translates to:
  /// **'Post again'**
  String get postAgain;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @deliveryEstimate.
  ///
  /// In en, this message translates to:
  /// **'Delivery estimate'**
  String get deliveryEstimate;

  /// No description provided for @ongoingLoads.
  ///
  /// In en, this message translates to:
  /// **'Ongoing loads'**
  String get ongoingLoads;

  /// No description provided for @noLoads.
  ///
  /// In en, this message translates to:
  /// **'No loads yet'**
  String get noLoads;

  /// No description provided for @unitBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get unitBags;

  /// No description provided for @unitCrates.
  ///
  /// In en, this message translates to:
  /// **'Crates'**
  String get unitCrates;

  /// No description provided for @unitBoxes.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get unitBoxes;

  /// No description provided for @unitTonnes.
  ///
  /// In en, this message translates to:
  /// **'Tonnes'**
  String get unitTonnes;

  /// No description provided for @unitLitres.
  ///
  /// In en, this message translates to:
  /// **'Litres'**
  String get unitLitres;

  /// No description provided for @vehOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Open body'**
  String get vehOpenBody;

  /// No description provided for @vehClosedBody.
  ///
  /// In en, this message translates to:
  /// **'Closed body'**
  String get vehClosedBody;

  /// No description provided for @vehContainer.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get vehContainer;

  /// No description provided for @vehRefrigerated.
  ///
  /// In en, this message translates to:
  /// **'Refrigerated'**
  String get vehRefrigerated;

  /// No description provided for @vehTanker.
  ///
  /// In en, this message translates to:
  /// **'Tanker'**
  String get vehTanker;

  /// No description provided for @vehAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get vehAny;

  /// No description provided for @crPlansChanged.
  ///
  /// In en, this message translates to:
  /// **'My plans changed'**
  String get crPlansChanged;

  /// No description provided for @crGoodsNotReady.
  ///
  /// In en, this message translates to:
  /// **'Goods not ready'**
  String get crGoodsNotReady;

  /// No description provided for @crFoundOtherTruck.
  ///
  /// In en, this message translates to:
  /// **'Found another truck'**
  String get crFoundOtherTruck;

  /// No description provided for @crDriverNotReachable.
  ///
  /// In en, this message translates to:
  /// **'Driver not reachable'**
  String get crDriverNotReachable;

  /// No description provided for @crDriverDidNotCome.
  ///
  /// In en, this message translates to:
  /// **'Driver did not come'**
  String get crDriverDidNotCome;

  /// No description provided for @crDriverAskedMore.
  ///
  /// In en, this message translates to:
  /// **'Driver asked for more money'**
  String get crDriverAskedMore;

  /// No description provided for @crTruckBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Truck breakdown'**
  String get crTruckBreakdown;

  /// No description provided for @crEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get crEmergency;

  /// No description provided for @crShipperChangedDetails.
  ///
  /// In en, this message translates to:
  /// **'Shipper changed the details'**
  String get crShipperChangedDetails;

  /// No description provided for @crAmountNotAgreed.
  ///
  /// In en, this message translates to:
  /// **'Amount not agreed'**
  String get crAmountNotAgreed;

  /// No description provided for @crTooFar.
  ///
  /// In en, this message translates to:
  /// **'Too far'**
  String get crTooFar;

  /// No description provided for @crOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get crOther;

  /// No description provided for @loadDetails.
  ///
  /// In en, this message translates to:
  /// **'Load details'**
  String get loadDetails;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @onDuty.
  ///
  /// In en, this message translates to:
  /// **'On duty'**
  String get onDuty;

  /// No description provided for @offDuty.
  ///
  /// In en, this message translates to:
  /// **'Off duty'**
  String get offDuty;

  /// No description provided for @goOnDutyHint.
  ///
  /// In en, this message translates to:
  /// **'Go on duty to get trip suggestions'**
  String get goOnDutyHint;

  /// No description provided for @myTruck.
  ///
  /// In en, this message translates to:
  /// **'My truck'**
  String get myTruck;

  /// No description provided for @addTruck.
  ///
  /// In en, this message translates to:
  /// **'Add my truck'**
  String get addTruck;

  /// No description provided for @truckNumber.
  ///
  /// In en, this message translates to:
  /// **'Truck number'**
  String get truckNumber;

  /// No description provided for @capacityTonnes.
  ///
  /// In en, this message translates to:
  /// **'Capacity (tonnes)'**
  String get capacityTonnes;

  /// No description provided for @truckAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get truckAvailable;

  /// No description provided for @truckAllocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get truckAllocated;

  /// No description provided for @truckOnTrip.
  ///
  /// In en, this message translates to:
  /// **'On trip'**
  String get truckOnTrip;

  /// No description provided for @truckDocumentsPending.
  ///
  /// In en, this message translates to:
  /// **'Documents pending'**
  String get truckDocumentsPending;

  /// No description provided for @truckInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get truckInactive;

  /// No description provided for @truckDocuments.
  ///
  /// In en, this message translates to:
  /// **'Truck documents'**
  String get truckDocuments;

  /// No description provided for @invitationFrom.
  ///
  /// In en, this message translates to:
  /// **'{org} invited you to drive for them'**
  String invitationFrom(String org);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @suggestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} trip suggestions'**
  String suggestionsAvailable(int count);

  /// No description provided for @expiringDocs.
  ///
  /// In en, this message translates to:
  /// **'Documents expiring soon'**
  String get expiringDocs;

  /// No description provided for @locker.
  ///
  /// In en, this message translates to:
  /// **'Document locker'**
  String get locker;

  /// No description provided for @truckAssignedBy.
  ///
  /// In en, this message translates to:
  /// **'Truck assigned by {org}'**
  String truckAssignedBy(String org);

  /// No description provided for @openTrip.
  ///
  /// In en, this message translates to:
  /// **'Open current trip'**
  String get openTrip;

  /// No description provided for @noTruckYet.
  ///
  /// In en, this message translates to:
  /// **'No truck yet'**
  String get noTruckYet;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Organization invitations'**
  String get invitations;

  /// No description provided for @sortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortNearest;

  /// No description provided for @sortAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sortAmount;

  /// No description provided for @sortEarliest.
  ///
  /// In en, this message translates to:
  /// **'Earliest'**
  String get sortEarliest;

  /// No description provided for @acceptTrip.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptTrip;

  /// No description provided for @acceptConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this trip?'**
  String get acceptConfirmTitle;

  /// No description provided for @acceptConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Amount {amount}. Trip charge {charge} is deducted now.'**
  String acceptConfirmBody(String amount, String charge);

  /// No description provided for @rejectTrip.
  ///
  /// In en, this message translates to:
  /// **'Not interested'**
  String get rejectTrip;

  /// No description provided for @rejectWhy.
  ///
  /// In en, this message translates to:
  /// **'Why not?'**
  String get rejectWhy;

  /// No description provided for @rrTooFar.
  ///
  /// In en, this message translates to:
  /// **'Too far'**
  String get rrTooFar;

  /// No description provided for @rrLowAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount too low'**
  String get rrLowAmount;

  /// No description provided for @rrWrongTruck.
  ///
  /// In en, this message translates to:
  /// **'Wrong truck'**
  String get rrWrongTruck;

  /// No description provided for @preferredTag.
  ///
  /// In en, this message translates to:
  /// **'Preferred by this shipper'**
  String get preferredTag;

  /// No description provided for @toPickup.
  ///
  /// In en, this message translates to:
  /// **'{km} away · {minutes} min to pickup'**
  String toPickup(String km, int minutes);

  /// No description provided for @topUpToSeeTrips.
  ///
  /// In en, this message translates to:
  /// **'Top up to see trips'**
  String get topUpToSeeTrips;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No trips right now. New ones arrive every few minutes.'**
  String get noSuggestions;

  /// No description provided for @driverSection.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverSection;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @tripAccepted.
  ///
  /// In en, this message translates to:
  /// **'Trip accepted'**
  String get tripAccepted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
