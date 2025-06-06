// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Login Demo';

  @override
  String get loginPageTitle => 'Enter Your Phone Number';

  @override
  String get themeSelectionPageTitle => 'Select Theme';

  @override
  String get verifyPhoneNumber => 'Verify your phone number';

  @override
  String get enterCountryCodeAndPhoneNumber =>
      'Please enter your country code and phone number to continue.';

  @override
  String get countryCode => 'Country Code';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => 'e.g. 1234567890';

  @override
  String get getPairingCodeButton => 'Get Pairing Code';

  @override
  String get termsAndConditions =>
      'By continuing, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get search => 'Search';

  @override
  String get startTypingToSearch => 'Start typing to search';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String loginAttemptWith(String fullPhoneNumber) {
    return 'Login attempt with $fullPhoneNumber';
  }

  @override
  String get pleaseCorrectErrors => 'Please correct the errors in the form.';

  @override
  String get chooseTheme => 'Choose your preferred theme:';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get lightModeSubtitle => 'WhatsApp-inspired light theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Standard dark theme';

  @override
  String get changeThemeTooltip => 'Change Theme';

  @override
  String get bottomNavNumbers => 'Numbers';

  @override
  String get bottomNavShop => 'Shop';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String get monitoredNumbersTitle => 'Monitored Numbers';

  @override
  String get addNumberButton => 'Add Number';

  @override
  String get noMonitoredNumbers => 'No Numbers Monitored Yet';

  @override
  String get noMonitoredNumbersHint =>
      'Tap the \'+\' button to add a number and start monitoring their online status.';

  @override
  String get addNumberPageTitle => 'Add Number to Monitor';

  @override
  String get addNumberInstructions =>
      'Enter the phone number and an optional display name for the contact you wish to monitor.';

  @override
  String get phoneNumberToMonitor => 'Phone Number to Monitor';

  @override
  String get displayNameOptional => 'Display Name (Optional)';

  @override
  String get displayNameHint => 'e.g., Work Phone, Alice';

  @override
  String get addingButton => 'Adding...';

  @override
  String get errorOwnerNumberMissing =>
      'Logged in user information is missing. Cannot add number.';

  @override
  String get successNumberAdded => 'Number added for monitoring!';

  @override
  String get errorAddingNumber => 'Error adding number';

  @override
  String get linkDeviceTitle => 'Link Device';

  @override
  String get loginSuccessfulNavigating => 'Login successful! Navigating...';

  @override
  String get retryConnectionButton => 'Retry Connection Check';

  @override
  String get retryingConnection => 'Retrying connection...';

  @override
  String get errorFetchingUserJid =>
      'Could not fetch user details. Please try logging in again.';

  @override
  String get errorCouldNotVerifySession =>
      'Could not verify session details. Please retry.';

  @override
  String get initializingText => 'Initializing...';

  @override
  String get statusAlreadyConnected => 'Already connected! Redirecting...';

  @override
  String get statusAttemptingReconnect =>
      'Attempting to connect with existing credentials. Checking status...';

  @override
  String get statusPairingInstruction =>
      'Please enter the pairing code below on your primary WhatsApp device.';

  @override
  String get pairingCodeLabel => 'Pairing Code';

  @override
  String get statusCheckingConnection => 'Checking connection status...';

  @override
  String get statusConnected => 'Connected!';

  @override
  String get statusWaitingForConnection => 'Waiting for connection...';

  @override
  String get statusSuccessfullyConnected =>
      'Successfully connected! Redirecting...';

  @override
  String get errorCheckingStatus => 'Error checking status';

  @override
  String get statusRetrying => 'Retrying...';

  @override
  String get sessionConflictMessage =>
      'Session conflict. Please re-pair this device.';
}
