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
