import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppStyles {
  // GENERAL SIZING HELPER
  static bool get isWeb => SizerUtil.deviceType == DeviceType.web;

  // PADDINGS & MARGINS
  static double get screenHorizontalPadding => isWeb ? 40.0 : 6.w;
  static double get screenVerticalPadding => isWeb ? 30.0 : 3.h;
  static double get formHorizontalPadding => isWeb ? 40.0 : 6.w; // For the inner card on login page
  static double get formVerticalPadding => isWeb ? 30.0 : 3.h;   // For the inner card on login page
  static double get pageHorizontalPadding => isWeb ? 24.0 : 4.w; // For theme selection page card
  static double get pageVerticalPadding => isWeb ? 24.0 : 4.w;   // For theme selection page card

  static double get defaultSpacing => isWeb ? 20.0 : 2.5.h; // Adjusted for better balance
  static double get smallSpacing => isWeb ? 10.0 : 1.2.h;
  static double get largeSpacing => isWeb ? 30.0 : 3.5.h;
  static double get itemSpacing => isWeb ? 10.0 : 2.w; // Spacing between items in a row

  // FONT SIZES
  static double get appBarTitleSize => isWeb ? 20.0 : 16.sp;
  static double get pageTitleSize => isWeb ? 24.0 : 17.sp;
  static double get pageSubtitleSize => isWeb ? 15.0 : 11.sp;
  static double get bodyTextSize => isWeb ? 16.0 : 12.sp; // For general text like in input fields
  static double get buttonTextSize => isWeb ? 16.0 : 13.sp;
  static double get smallTextSize => isWeb ? 12.0 : 9.sp; // For terms, etc.
  static double get listTileTitleSize => isWeb ? 16.0 : 12.sp;
  static double get listTileSubtitleSize => isWeb ? 14.0 : 10.sp;

  static double get countryPickerListTextSize => isWeb ? 15.0 : 12.sp;
  static double get countryPickerSearchTextSize => isWeb ? 16.0 : 13.sp;
  static double get snackBarTextSize => isWeb ? 14.0 : 10.sp;

  // ICON SIZES
  static double get largeIconSize => isWeb ? 60.0 : 18.w; // e.g. main message icon
  static double get mediumIconSize => isWeb ? 24.0 : 6.w; // For app bar icons, dropdowns, list tile icons
  static double get flagEmojiSize => isWeb ? 28.0 : 6.w;

  // BORDER RADIUS
  static double get borderRadiusSmall => isWeb ? 8.0 : 2.w;
  static double get borderRadiusMedium => isWeb ? 12.0 : 3.w; // For cards on web
  static double get borderRadiusCountryPickerSheet => isWeb ? 12.0 : 5.w;


  // LAYOUT
  static double get maxFormWidth => 480.0; // Max width for login form on web
  static double get maxPageContentWidth => 500.0; // Max width for theme selection page on web

  // ELEVATION
  static double get cardElevationWeb => 6.0;
  static double get cardElevationMobileLight => 0.0;
  static double get cardElevationMobileDark => 1.0;

  // SNACKBAR MARGINS
  static EdgeInsets get snackBarMarginWeb => EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h);
  static EdgeInsets get snackBarMarginMobile => EdgeInsets.all(2.w);
}
