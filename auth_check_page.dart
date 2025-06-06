// File: lib/auth_check_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_login_demo/app_styles.dart'; 
import 'package:flutter_login_demo/login_page.dart'; 
import 'package:flutter_login_demo/main_page.dart'; 
import 'package:flutter_login_demo/services/api_service.dart'; 

// Key for shared_preferences to store the app's unique device ID
const String kDeviceIdKey = 'user_device_id';
// kServerPhoneNumberKey and kJidKey are no longer used by this page for session checks.

// Helper function to get or generate a consistent device ID for the app instance.
Future<String> getAppDeviceId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString(kDeviceIdKey);
  if (deviceId == null || deviceId.isEmpty) {
    deviceId = 'flutter_device_${DateTime.now().microsecondsSinceEpoch}_${UniqueKey().toString().replaceAll('[#', '').replaceAll(']', '')}';
    await prefs.setString(kDeviceIdKey, deviceId);
    print('AuthCheck/getAppDeviceId: Generated and saved new deviceId: $deviceId');
  }
  return deviceId;
}


class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkDeviceSession();
  }

  Future<void> _checkDeviceSession() async {
    await Future.delayed(const Duration(milliseconds: 200)); // For splash screen visibility

    final String currentAppDeviceId = await getAppDeviceId();
    print('AuthCheck: Current App Device ID: $currentAppDeviceId. Checking session with backend...');

    // NEW: Call a backend endpoint that checks session status based on deviceId
    // This endpoint needs to be created on your Node.js backend.
    // It should return if the deviceId has an active, logged-in session,
    // and if so, the associated JID and phone number part.
    _apiService.sendRequest<Map<String, dynamic>>(
      // Example endpoint: you'll need to define and implement this on your server
      endpoint: '/check-session-by-device/$currentAppDeviceId', 
      method: HttpMethod.get,
      onSuccess: (data) {
        if (!mounted) return; 

        final bool isLoggedIn = data['isLoggedIn'] == true;
        final String? jid = data['jid'] as String?; // Full JID from server
        // final String? serverPhoneNumber = data['phoneNumber'] as String?; // Number part, if needed
        // final bool isActiveSession = data['isActiveSession'] == true; // If backend provides this

        print('AuthCheck: API Response for Device $currentAppDeviceId - isLoggedIn: $isLoggedIn, JID: $jid');
        
        if (isLoggedIn && jid != null && jid.isNotEmpty) {
          print('AuthCheck: Device $currentAppDeviceId has a valid session with JID $jid. Navigating to MainPage.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(ownerPhoneNumber: jid)),
          );
        } else {
          print('AuthCheck: No valid session found for Device $currentAppDeviceId (isLoggedIn: $isLoggedIn, jid: $jid). Navigating to LoginPage.');
          _navigateToLogin();
        }
      },
      onError: (errorMessage, statusCode) {
        if (!mounted) return;
        print("AuthCheck: Error checking session for Device $currentAppDeviceId: $errorMessage (Code: $statusCode). Navigating to LoginPage.");
        _navigateToLogin();
      },
    );
  }

  void _navigateToLogin() {
    // No session data to clear here based on the new flow, as we only rely on deviceId.
    // If the server invalidates a deviceId, that's a server-side concern.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: AppStyles.defaultSpacing), 
            Text(
              'Initializing...', // TODO: Localize this string
              style: TextStyle(
                fontSize: AppStyles.bodyTextSize, 
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
