
// File: lib/tabs/settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/app_styles.dart'; // Replace your_app_name
import 'package:flutter_login_demo/l10n/app_localizations.dart'; // Replace your_app_name

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
     final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.bottomNavSettings,
          style: TextStyle(fontSize: AppStyles.appBarTitleSize),
        ),
      ),
      body: Center(
        child: Text(
          '${appLocalizations.bottomNavSettings} Page - Content Coming Soon!',
          style: TextStyle(fontSize: AppStyles.bodyTextSize),
        ),
      ),
    );
  }
}