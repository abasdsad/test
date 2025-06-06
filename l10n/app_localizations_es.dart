// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Demostración de Inicio de Sesión en Flutter';

  @override
  String get loginPageTitle => 'Ingrese su Número de Teléfono';

  @override
  String get themeSelectionPageTitle => 'Seleccionar Tema';

  @override
  String get verifyPhoneNumber => 'Verifique su número de teléfono';

  @override
  String get enterCountryCodeAndPhoneNumber =>
      'Por favor, ingrese el código de su país y su número de teléfono para continuar.';

  @override
  String get countryCode => 'Código de País';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get phoneNumberHint => 'ej. 1234567890';

  @override
  String get getPairingCodeButton => 'Get Pairing Code';

  @override
  String get termsAndConditions =>
      'Al continuar, acepta nuestros Términos de Servicio y Política de Privacidad.';

  @override
  String get search => 'Buscar';

  @override
  String get startTypingToSearch => 'Comience a escribir para buscar';

  @override
  String get pleaseEnterPhoneNumber =>
      'Por favor ingrese su número de teléfono';

  @override
  String get enterValidPhoneNumber => 'Ingrese un número de teléfono válido';

  @override
  String loginAttemptWith(String fullPhoneNumber) {
    return 'Intento de inicio de sesión con $fullPhoneNumber';
  }

  @override
  String get pleaseCorrectErrors =>
      'Por favor corrija los errores en el formulario.';

  @override
  String get chooseTheme => 'Elige tu tema preferido:';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get lightModeSubtitle => 'Tema claro inspirado en WhatsApp';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeSubtitle => 'Tema oscuro estándar';

  @override
  String get changeThemeTooltip => 'Cambiar Tema';

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
