// File: lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_login_demo/l10n/app_localizations.dart';
import 'package:flutter_login_demo/theme_provider.dart';
import 'package:flutter_login_demo/app_styles.dart';
import 'package:flutter_login_demo/services/api_service.dart';
import 'package:flutter_login_demo/login_status_checker_page.dart';
import 'package:flutter_login_demo/auth_check_page.dart'; // Import for getAppDeviceId

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  Country _selectedCountry = Country(
    phoneCode: '1',
    countryCode: 'US',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'United States',
    example: '2015550123',
    displayName: 'United States (US) [+1]',
    displayNameNoCountryCode: 'United States (US)',
    e164Key: '1-US-0',
  );

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  void _showCountryPicker() {
    final appLocalizations = AppLocalizations.of(context)!;
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppStyles.borderRadiusCountryPickerSheet),
          topRight: Radius.circular(AppStyles.borderRadiusCountryPickerSheet),
        ),
        inputDecoration: InputDecoration(
          labelText: appLocalizations.search,
          hintText: appLocalizations.startTypingToSearch,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        textStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: AppStyles.countryPickerListTextSize,
        ),
        searchTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: AppStyles.countryPickerSearchTextSize,
        ),
      ),
    );
  }

  Future<void> _requestPairingCode() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Get the consistent device ID for this app instance
    final String currentDeviceId = await getAppDeviceId();
    print('LoginPage: Using Device ID for pairing request: $currentDeviceId');

    final String plainPhoneNumber = _phoneNumberController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    // For the backend /request-pairing-code, send the number part (e.g., 12223334444)
    // The backend's requestPairingCode for Baileys also expects just the number part.
    final String phoneNumberForServer = _selectedCountry.phoneCode + plainPhoneNumber;
    final String displayPhoneNumber = '+${_selectedCountry.phoneCode} $plainPhoneNumber'; // For display purposes

    await _apiService.sendRequest<Map<String, dynamic>>(
      endpoint: '/request-pairing-code',
      method: HttpMethod.post,
      body: {
        'phoneNumber': phoneNumberForServer, // This is the number user wants to pair
        'deviceId': currentDeviceId // Send the app's unique deviceId
      },
      onSuccess: (data) {
        if (!mounted) return;
        setState(() { _isLoading = false; });

        final String? pairingCode = data['pairingCode'] as String?;
        // Backend might return 'phoneNumberPaired' which is the number part used for Baileys session
        final String? actualPhoneNumberPaired = data['phoneNumberPaired'] as String?;
        final bool alreadyConnected = data['alreadyConnected'] == true; // Assuming backend might send this
        String serverMessage = (data['message'] as String?) ?? "Request processed.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverMessage, style: TextStyle(fontSize: AppStyles.snackBarTextSize)),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall)),
            margin: AppStyles.isWeb ? AppStyles.snackBarMarginWeb : AppStyles.snackBarMarginMobile,
          ),
        );
        
        // Use actualPhoneNumberPaired (number part) for serverPhoneNumber in LoginStatusCheckerPage
        // If backend doesn't send it, fallback to phoneNumberForServer (which should be the same)
        final String numberPartForStatusCheck = actualPhoneNumberPaired ?? phoneNumberForServer;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginStatusCheckerPage(
              displayPhoneNumber: displayPhoneNumber,
              serverPhoneNumber: numberPartForStatusCheck, // Number part for API calls
              pairingCode: pairingCode,
              initiallyAlreadyConnected: alreadyConnected,
              deviceIdForSession: currentDeviceId, // Pass the fetched deviceId
            ),
          ),
        );
      },
      onError: (errorMessage, statusCode) {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${appLocalizations.pleaseCorrectErrors} (Status: $statusCode): $errorMessage',
              style: TextStyle(fontSize: AppStyles.snackBarTextSize),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall)),
            margin: AppStyles.isWeb ? AppStyles.snackBarMarginWeb : AppStyles.snackBarMarginMobile,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context)!;
    final isLightMode = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppStyles.isWeb
          ? (isLightMode ? webPageBackgroundColor : theme.scaffoldBackgroundColor)
          : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appLocalizations.loginPageTitle,
          style: TextStyle(fontSize: AppStyles.appBarTitleSize),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              size: AppStyles.mediumIconSize,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/theme_selection');
            },
            tooltip: appLocalizations.changeThemeTooltip,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppStyles.isWeb ? AppStyles.maxFormWidth : double.infinity),
          child: Material(
            elevation: AppStyles.isWeb
                ? AppStyles.cardElevationWeb
                : (isLightMode ? AppStyles.cardElevationMobileLight : AppStyles.cardElevationMobileDark),
            color: AppStyles.isWeb
                ? (isLightMode ? Colors.white : theme.colorScheme.background)
                : theme.scaffoldBackgroundColor,
            shape: AppStyles.isWeb
                ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium))
                : null,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyles.formHorizontalPadding,
                vertical: AppStyles.formVerticalPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.message,
                      size: AppStyles.largeIconSize,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: AppStyles.defaultSpacing),
                    Text(
                      appLocalizations.verifyPhoneNumber,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: AppStyles.pageTitleSize,
                        fontWeight: AppStyles.isWeb ? FontWeight.w600 : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppStyles.smallSpacing),
                    Text(
                      appLocalizations.enterCountryCodeAndPhoneNumber,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppStyles.pageSubtitleSize,
                      ),
                    ),
                    SizedBox(height: AppStyles.largeSpacing),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _showCountryPicker,
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppStyles.isWeb ? 12 : AppStyles.itemSpacing * 1.5,
                                vertical: AppStyles.isWeb ? 15.5 : AppStyles.defaultSpacing * 0.72),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey),
                              borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
                              color: theme.inputDecorationTheme.fillColor,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedCountry.flagEmoji,
                                  style: TextStyle(fontSize: AppStyles.flagEmojiSize),
                                ),
                                SizedBox(width: AppStyles.itemSpacing),
                                Text(
                                  '+${_selectedCountry.phoneCode}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppStyles.bodyTextSize,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: theme.iconTheme.color, size: AppStyles.mediumIconSize)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: AppStyles.itemSpacing),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(fontSize: AppStyles.bodyTextSize),
                            decoration: InputDecoration(
                              labelText: appLocalizations.phoneNumber,
                              hintText: appLocalizations.phoneNumberHint,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return appLocalizations.pleaseEnterPhoneNumber;
                              }
                              final plainNumber = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
                              if (plainNumber.length < 7 || plainNumber.length > 15) {
                                 return appLocalizations.enterValidPhoneNumber;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppStyles.largeSpacing),
                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        textStyle: MaterialStateProperty.all(
                           TextStyle(fontSize: AppStyles.buttonTextSize, fontWeight: FontWeight.bold)
                        ),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: AppStyles.isWeb ? 16 : AppStyles.defaultSpacing * 0.72)
                        )
                      ),
                      onPressed: _isLoading ? null : _requestPairingCode,
                      child: _isLoading
                          ? SizedBox(
                              width: AppStyles.buttonTextSize,
                              height: AppStyles.buttonTextSize,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? Colors.white
                                ),
                              ),
                            )
                          : Text(appLocalizations.getPairingCodeButton), // Using localized string
                    ),
                    SizedBox(height: AppStyles.defaultSpacing),
                    Text(
                      appLocalizations.termsAndConditions,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: AppStyles.smallTextSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
