import 'package:flutter/material.dart';
import 'package:flutter_login_demo/app_styles.dart'; // Replace your_app_name
import 'package:flutter_login_demo/l10n/app_localizations.dart'; // Replace your_app_name

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.bottomNavShop,
          style: TextStyle(fontSize: AppStyles.appBarTitleSize),
        ),
      ),
      body: Center(
        child: Text(
          '${appLocalizations.bottomNavShop} Page - Content Coming Soon!',
          style: TextStyle(fontSize: AppStyles.bodyTextSize),
        ),
      ),
    );
  }
}
