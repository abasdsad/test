import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart'; 
import 'theme_provider.dart';

class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isWeb = SizerUtil.deviceType == DeviceType.web;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Theme',
          style: TextStyle(fontSize: isWeb ? 20.0 : 16.sp), 
        ),
      ),
      body: Center( // Center content on web
        child: ConstrainedBox( // Max width for web
          constraints: BoxConstraints(maxWidth: isWeb ? 500 : double.infinity),
          child: Material( // Use Material for potential card-like appearance on web
            elevation: isWeb ? 4.0 : 0.0,
            color: isWeb ? Theme.of(context).colorScheme.surface : Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 24.0 : 4.w), 
              child: Column(
                mainAxisSize: MainAxisSize.min, // So the card doesn't take full height
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your preferred theme:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: isWeb ? 15.sp : 20.sp, 
                        ),
                  ),
                  SizedBox(height: isWeb ? 20 : 2.5.h), 
                  RadioListTile<ThemeMode>(
                    title: Text('Light Mode', style: TextStyle(fontSize: isWeb ? 16.0 : 12.sp)), 
                    subtitle: Text('WhatsApp-inspired light theme', style: TextStyle(fontSize: isWeb ? 14.0 : 10.sp)), 
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                    secondary: Icon(Icons.wb_sunny, size: isWeb ? 24.0 : 6.w), 
                    activeColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 0),
                  ),
                  const Divider(),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark Mode', style: TextStyle(fontSize: isWeb ? 16.0 : 12.sp)), 
                    subtitle: Text('Standard dark theme', style: TextStyle(fontSize: isWeb ? 14.0 : 10.sp)), 
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                    secondary: Icon(Icons.nightlight_round, size: isWeb ? 24.0 : 6.w), 
                    activeColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 0),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}