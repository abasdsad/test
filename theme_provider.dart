// File: lib/theme_provider.dart
import 'package:flutter/material.dart';
// No localizable strings are directly in this file, so no AppLocalizations import needed here.

// Define WhatsApp-like green color
const Color whatsappGreen = Color(0xFF075E54); // Dark green for app bar
const Color whatsappLightGreen = Color(0xFF25D366); // Lighter green for accents/buttons
const Color whatsappChatBackgroundColor = Color(0xFFECE5DD); // Chat background color (WhatsApp mobile)
const Color webPageBackgroundColor = Color(0xFFF0F2F5); // Common web page background (like WhatsApp Web)
const Color whatsappLightTealGreen = Color(0xFF128C7E); // Slightly lighter than app bar green

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Light theme (WhatsApp inspired)
  ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: whatsappGreen,
      scaffoldBackgroundColor: whatsappChatBackgroundColor,
      colorScheme: ColorScheme.light(
        primary: whatsappGreen,
        secondary: whatsappLightGreen,
        surface: Colors.white,
        background: whatsappChatBackgroundColor,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: whatsappGreen,
        elevation: 0.0, 
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0, // Base size, AppStyles.appBarTitleSize will be used in widget
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whatsappLightGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Base, AppStyles.buttonTextSize in widget
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey[500]),
        labelStyle: const TextStyle(color: whatsappLightTealGreen, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: whatsappLightGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme( // Base styles, specific font sizes applied via AppStyles in widgets
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: Colors.grey), 
      ),
      iconTheme: const IconThemeData(
        color: whatsappLightTealGreen,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: whatsappLightGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Dark theme
  ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.tealAccent[700],
      scaffoldBackgroundColor: Colors.grey[900],
      colorScheme: ColorScheme.dark(
        primary: Colors.tealAccent[400]!,
        secondary: Colors.pinkAccent[200]!,
        surface: Colors.grey[800]!,
        background: Colors.grey[850]!,
        error: Colors.redAccent.shade100,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0, // Base size
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent[400],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Base size
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[700]?.withOpacity(0.7),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: TextStyle(color: Colors.tealAccent[200], fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.tealAccent[400]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.redAccent.shade100, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: TextTheme( // Base styles
        bodyLarge: TextStyle(color: Colors.white.withOpacity(0.87)),
        bodyMedium: TextStyle(color: Colors.white.withOpacity(0.60)),
        titleLarge: TextStyle(color: Colors.white.withOpacity(0.87), fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: Colors.grey[400]),
      ),
      iconTheme: IconThemeData(
        color: Colors.tealAccent[200],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.pinkAccent[200],
        foregroundColor: Colors.black,
      ),
    );
  }
}
