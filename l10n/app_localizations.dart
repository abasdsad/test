import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Login Demo'**
  String get appTitle;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get loginPageTitle;

  /// No description provided for @themeSelectionPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get themeSelectionPageTitle;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyPhoneNumber;

  /// No description provided for @enterCountryCodeAndPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your country code and phone number to continue.'**
  String get enterCountryCodeAndPhoneNumber;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get countryCode;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1234567890'**
  String get phoneNumberHint;

  /// No description provided for @getPairingCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Get Pairing Code'**
  String get getPairingCodeButton;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy.'**
  String get termsAndConditions;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startTypingToSearch;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// Message shown after login attempt
  ///
  /// In en, this message translates to:
  /// **'Login attempt with {fullPhoneNumber}'**
  String loginAttemptWith(String fullPhoneNumber);

  /// No description provided for @pleaseCorrectErrors.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form.'**
  String get pleaseCorrectErrors;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme:'**
  String get chooseTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @lightModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp-inspired light theme'**
  String get lightModeSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @changeThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeThemeTooltip;

  /// No description provided for @bottomNavNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get bottomNavNumbers;

  /// No description provided for @bottomNavShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get bottomNavShop;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// No description provided for @monitoredNumbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitored Numbers'**
  String get monitoredNumbersTitle;

  /// No description provided for @addNumberButton.
  ///
  /// In en, this message translates to:
  /// **'Add Number'**
  String get addNumberButton;

  /// No description provided for @noMonitoredNumbers.
  ///
  /// In en, this message translates to:
  /// **'No Numbers Monitored Yet'**
  String get noMonitoredNumbers;

  /// No description provided for @noMonitoredNumbersHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to add a number and start monitoring their online status.'**
  String get noMonitoredNumbersHint;

  /// No description provided for @addNumberPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Number to Monitor'**
  String get addNumberPageTitle;

  /// No description provided for @addNumberInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number and an optional display name for the contact you wish to monitor.'**
  String get addNumberInstructions;

  /// No description provided for @phoneNumberToMonitor.
  ///
  /// In en, this message translates to:
  /// **'Phone Number to Monitor'**
  String get phoneNumberToMonitor;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Display Name (Optional)'**
  String get displayNameOptional;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Work Phone, Alice'**
  String get displayNameHint;

  /// No description provided for @addingButton.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get addingButton;

  /// No description provided for @errorOwnerNumberMissing.
  ///
  /// In en, this message translates to:
  /// **'Logged in user information is missing. Cannot add number.'**
  String get errorOwnerNumberMissing;

  /// No description provided for @successNumberAdded.
  ///
  /// In en, this message translates to:
  /// **'Number added for monitoring!'**
  String get successNumberAdded;

  /// No description provided for @errorAddingNumber.
  ///
  /// In en, this message translates to:
  /// **'Error adding number'**
  String get errorAddingNumber;

  /// No description provided for @linkDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Device'**
  String get linkDeviceTitle;

  /// No description provided for @loginSuccessfulNavigating.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Navigating...'**
  String get loginSuccessfulNavigating;

  /// No description provided for @retryConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection Check'**
  String get retryConnectionButton;

  /// No description provided for @retryingConnection.
  ///
  /// In en, this message translates to:
  /// **'Retrying connection...'**
  String get retryingConnection;

  /// No description provided for @errorFetchingUserJid.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch user details. Please try logging in again.'**
  String get errorFetchingUserJid;

  /// No description provided for @errorCouldNotVerifySession.
  ///
  /// In en, this message translates to:
  /// **'Could not verify session details. Please retry.'**
  String get errorCouldNotVerifySession;

  /// No description provided for @initializingText.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializingText;

  /// No description provided for @statusAlreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'Already connected! Redirecting...'**
  String get statusAlreadyConnected;

  /// No description provided for @statusAttemptingReconnect.
  ///
  /// In en, this message translates to:
  /// **'Attempting to connect with existing credentials. Checking status...'**
  String get statusAttemptingReconnect;

  /// No description provided for @statusPairingInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please enter the pairing code below on your primary WhatsApp device.'**
  String get statusPairingInstruction;

  /// No description provided for @pairingCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pairing Code'**
  String get pairingCodeLabel;

  /// No description provided for @statusCheckingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking connection status...'**
  String get statusCheckingConnection;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected!'**
  String get statusConnected;

  /// No description provided for @statusWaitingForConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection...'**
  String get statusWaitingForConnection;

  /// No description provided for @statusSuccessfullyConnected.
  ///
  /// In en, this message translates to:
  /// **'Successfully connected! Redirecting...'**
  String get statusSuccessfullyConnected;

  /// No description provided for @errorCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Error checking status'**
  String get errorCheckingStatus;

  /// No description provided for @statusRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get statusRetrying;

  /// No description provided for @sessionConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'Session conflict. Please re-pair this device.'**
  String get sessionConflictMessage;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
