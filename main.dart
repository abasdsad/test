import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_login_demo/l10n/app_localizations.dart'; 

import 'package:flutter_login_demo/theme_provider.dart'; 
import 'package:flutter_login_demo/theme_selection_page.dart'; 
import 'package:flutter_login_demo/main_page.dart'; 
import 'package:flutter_login_demo/auth_check_page.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: themeProvider.getLightTheme(),
              darkTheme: themeProvider.getDarkTheme(),
              themeMode: themeProvider.themeMode,
              home: const AuthCheckPage(), 
              routes: {
                '/theme_selection': (context) => const ThemeSelectionPage(),
                MainPage.routeName: (context) => const MainPage(), 
              },
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
