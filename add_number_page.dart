// File: lib/add_number_page.dart
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_login_demo/app_styles.dart'; // Replace your_app_name
import 'package:flutter_login_demo/l10n/app_localizations.dart'; // Replace your_app_name
import 'package:flutter_login_demo/services/api_service.dart'; // Replace your_app_name


class AddNumberPage extends StatefulWidget {
  final String? ownerPhoneNumber; // The JID of the logged-in user

  const AddNumberPage({super.key, this.ownerPhoneNumber});

  @override
  State<AddNumberPage> createState() => _AddNumberPageState();
}

class _AddNumberPageState extends State<AddNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController(); // Optional display name

  Country _selectedCountry = Country(
    phoneCode: '1', // Default to US
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
        ),
      ),
    );
  }

  Future<void> _submitAddNumber() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.ownerPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.errorOwnerNumberMissing, style: TextStyle(fontSize: AppStyles.snackBarTextSize))),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final String plainPhoneNumber = _phoneNumberController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final String numberToMonitor = '+${_selectedCountry.phoneCode}$plainPhoneNumber'; // E.g., +12015550123
    final String? displayName = _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null;


    // API call to backend's /monitor-number endpoint
    print('Owner: ${widget.ownerPhoneNumber}, Number to Monitor: $numberToMonitor, Display Name: $displayName');

    await _apiService.sendRequest(
        endpoint: '/monitor-number',
        method: HttpMethod.post,
        body: {
          'ownerPhoneNumber': widget.ownerPhoneNumber, 
          'numberToMonitor': numberToMonitor, 
          'displayName': displayName, 
        },
        onSuccess: (data) { // data is dynamic
          setState(() { _isLoading = false; });
          String message = appLocalizations.successNumberAdded; // Default message

          if (data is Map && data.containsKey('message') && data['message'] != null) {
            message = data['message'] as String;
          } else if (data is Map && data['message'] == null) {
            // If server sends 'message: null', use default or specific handling
            message = appLocalizations.successNumberAdded; 
          }
          // If data is not a Map, or doesn't have 'message', the default 'successNumberAdded' will be used.

          if (!mounted) return; // Check if widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message, style: TextStyle(fontSize: AppStyles.snackBarTextSize)),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
          Navigator.pop(context, true); // Pop and indicate success
        },
        onError: (errorMessage, statusCode) {
          setState(() { _isLoading = false; });
          if (!mounted) return; // Check if widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${appLocalizations.errorAddingNumber}: $errorMessage (Code: $statusCode)', style: TextStyle(fontSize: AppStyles.snackBarTextSize)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
  }


  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.addNumberPageTitle,
          style: TextStyle(fontSize: AppStyles.appBarTitleSize),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.screenHorizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                appLocalizations.addNumberInstructions,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: AppStyles.bodyTextSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppStyles.largeSpacing),

              // Phone Number Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppStyles.itemSpacing * 1.5, vertical: AppStyles.defaultSpacing * 0.72),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey),
                        borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Text(_selectedCountry.flagEmoji, style: TextStyle(fontSize: AppStyles.flagEmojiSize)),
                          SizedBox(width: AppStyles.itemSpacing),
                          Text('+${_selectedCountry.phoneCode}', style: theme.textTheme.bodyLarge?.copyWith(fontSize: AppStyles.bodyTextSize)),
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
                        labelText: appLocalizations.phoneNumberToMonitor,
                        hintText: appLocalizations.phoneNumberHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return appLocalizations.pleaseEnterPhoneNumber;
                        }
                        if (value.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 7) {
                           return appLocalizations.enterValidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.defaultSpacing),

              // Display Name Input (Optional)
              TextFormField(
                controller: _displayNameController,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: AppStyles.bodyTextSize),
                decoration: InputDecoration(
                  labelText: appLocalizations.displayNameOptional,
                  hintText: appLocalizations.displayNameHint,
                ),
              ),
              SizedBox(height: AppStyles.largeSpacing * 1.5),

              ElevatedButton.icon(
                style: theme.elevatedButtonTheme.style?.copyWith(
                  textStyle: MaterialStateProperty.all(
                     TextStyle(fontSize: AppStyles.buttonTextSize, fontWeight: FontWeight.bold)
                  ),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: AppStyles.defaultSpacing * 0.72)
                  )
                ),
                onPressed: _isLoading ? null : _submitAddNumber,
                icon: _isLoading
                    ? Container(
                        width: AppStyles.buttonTextSize * 0.8,
                        height: AppStyles.buttonTextSize * 0.8,
                        margin: const EdgeInsets.only(right: 8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                        ),
                      )
                    : Icon(Icons.person_add_alt_1_rounded, size: AppStyles.mediumIconSize * 0.9),
                label: Text(_isLoading ? appLocalizations.addingButton : appLocalizations.addNumberButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
