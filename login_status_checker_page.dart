// File: lib/login_status_checker_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // No longer saving session JID/Phone here
import 'package:flutter_login_demo/l10n/app_localizations.dart'; 
import 'package:flutter_login_demo/services/api_service.dart'; 
import 'package:flutter_login_demo/app_styles.dart'; 
import 'package:flutter_login_demo/main_page.dart'; 
// Import for kDeviceIdKey and getAppDeviceId if needed, though deviceIdForSession is passed
import 'package:flutter_login_demo/auth_check_page.dart'; 

class LoginStatusCheckerPage extends StatefulWidget {
  final String displayPhoneNumber; 
  final String serverPhoneNumber;  // Number part for API calls during pairing
  final String? pairingCode;      
  final bool initiallyAlreadyConnected; 
  final String deviceIdForSession; // The deviceId of this app instance, used for this pairing

  const LoginStatusCheckerPage({
    super.key,
    required this.displayPhoneNumber,
    required this.serverPhoneNumber,
    this.pairingCode,
    required this.initiallyAlreadyConnected,
    required this.deviceIdForSession, 
  });

  @override
  State<LoginStatusCheckerPage> createState() => _LoginStatusCheckerPageState();
}

class _LoginStatusCheckerPageState extends State<LoginStatusCheckerPage> {
  final ApiService _apiService = ApiService();
  Timer? _pollingTimer;
  String _statusMessage = "Initializing..."; 
  bool _isChecking = false;
  String? _loggedInUserJid; // To store the full JID from the server upon successful pairing

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusMessage(); 
      if (widget.initiallyAlreadyConnected) {
        // If already connected, we still poll to confirm and get JID for *this* pairing attempt
        _checkLoginStatus(navigateToHomeOnSuccess: true);
      } else {
        _startPolling();
      }
    });
  }

  void _updateStatusMessage() {
    if (!mounted) return;
    final appLocalizations = AppLocalizations.of(context)!;
    setState(() {
      if (_isChecking && _loggedInUserJid == null) { 
         _statusMessage = widget.pairingCode != null
            ? "${appLocalizations.pairingCodeLabel}: ${widget.pairingCode}\n\n${appLocalizations.statusCheckingConnection}"
            : appLocalizations.statusCheckingConnection;
        return;
      }
      _statusMessage = widget.initiallyAlreadyConnected && _loggedInUserJid == null
          ? appLocalizations.statusAlreadyConnected 
          : (widget.pairingCode == null && _loggedInUserJid == null
              ? appLocalizations.statusAttemptingReconnect
              : (_loggedInUserJid != null 
                  ? appLocalizations.statusSuccessfullyConnected 
                  : "${appLocalizations.statusPairingInstruction}\n\n${appLocalizations.pairingCodeLabel}: ${widget.pairingCode}\n\n${appLocalizations.statusCheckingConnection}"));
    });
  }

  void _startPolling() {
    if (!mounted) return;
    setState(() {
      _isChecking = true;
    });
    _updateStatusMessage(); 
    _checkLoginStatus(navigateToHomeOnSuccess: true); 
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _isChecking) {
        _checkLoginStatus(navigateToHomeOnSuccess: true);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkLoginStatus({bool navigateToHomeOnSuccess = false}) async {
    if (!mounted) return;
    if (!navigateToHomeOnSuccess && !_isChecking) return;

    final appLocalizations = AppLocalizations.of(context)!;

    // This page polls /check-login-status for the *specific phone number being paired*.
    // It's part of the pairing flow, not the general app startup session check.
    await _apiService.sendRequest<Map<String, dynamic>>(
      endpoint: '/check-login-status/${widget.serverPhoneNumber}',
      method: HttpMethod.get,
      onSuccess: (data) {
        if (!mounted) return;

        final bool isLoggedIn = data['isLoggedIn'] == true;
        final String? serverJid = data['jid'] as String?;
        final String? deviceIdFromServer = data['deviceId'] as String?; 

        print('LoginStatusChecker: API Response for ${widget.serverPhoneNumber} - isLoggedIn: $isLoggedIn, serverJid: $serverJid, deviceIdFromServer: $deviceIdFromServer');

        if (isLoggedIn && serverJid != null) {
          // Crucially, verify that the session the server reports for this phoneNumber
          // is associated with THIS deviceId.
          if (deviceIdFromServer == widget.deviceIdForSession) {
            _loggedInUserJid = serverJid;
            print('LoginStatusChecker: Pairing successful for device ${widget.deviceIdForSession} with JID $serverJid.');
          } else {
            print('LoginStatusChecker Critical: Device ID mismatch during pairing! Server session for ${widget.serverPhoneNumber} is linked to ${deviceIdFromServer}, but this device is ${widget.deviceIdForSession}.');
            // This indicates that while the number might be logged in, it's not by this device's pairing attempt.
            // Stop polling and show an error. The user might need to re-initiate pairing.
            _loggedInUserJid = null; 
            if (mounted) {
              setState(() {
                _statusMessage = appLocalizations.sessionConflictMessage; // "Session conflict. Please re-pair this device."
                _isChecking = false; 
              });
            }
            _pollingTimer?.cancel();
            return; 
          }
        }
        
        if (mounted) {
          _updateStatusMessage(); 
          if (isLoggedIn && _loggedInUserJid != null && navigateToHomeOnSuccess) {
            _stopPollingAndNavigate();
          }
        }
      },
      onError: (errorMessage, statusCode) {
        if (!mounted) return;
        print("LoginStatusChecker: Error checking status for ${widget.serverPhoneNumber}: $errorMessage (Code: $statusCode)");
        if (mounted) {
          setState(() {
            _statusMessage = "${appLocalizations.errorCheckingStatus} (Code: $statusCode): $errorMessage\n${appLocalizations.statusRetrying}";
          });
        }
      },
    );
  }

  void _stopPollingAndNavigate() {
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
    _pollingTimer?.cancel();
    _navigateToHome(); 
  }

  // _saveSessionDetails is NO LONGER NEEDED here for kJidKey and kServerPhoneNumberKey
  // because AuthCheckPage now uses a deviceId-based check.
  // The kDeviceIdKey is already persisted by getAppDeviceId().

  Future<void> _navigateToHome() async {
    if (!mounted) return;
    final appLocalizations = AppLocalizations.of(context)!;
    
    if (_loggedInUserJid == null) {
      print('LoginStatusChecker: Navigation to home blocked, _loggedInUserJid is null (pairing likely failed or deviceId mismatch).');
      // Message is already updated by _checkLoginStatus in case of mismatch.
      // If it's just null without a specific error message being set:
      if (_statusMessage != appLocalizations.sessionConflictMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.errorFetchingUserJid, style: TextStyle(fontSize: AppStyles.snackBarTextSize))),
        );
      }
      if (mounted) {
        setState(() {
          if (_statusMessage != appLocalizations.sessionConflictMessage) { // Don't overwrite specific conflict message
            _statusMessage = appLocalizations.errorCouldNotVerifySession;
          }
          _isChecking = false; 
        });
      }
      return;
    }

    // No session details (JID/Phone) to save here anymore for AuthCheckPage.
    // The backend now associates the deviceId with the JID.

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appLocalizations.loginSuccessfulNavigating, style: TextStyle(fontSize: AppStyles.snackBarTextSize))),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainPage(ownerPhoneNumber: _loggedInUserJid!)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_statusMessage == "Initializing..." ) { // Simplified initial check
        _updateStatusMessage(); 
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.linkDeviceTitle, style: TextStyle(fontSize: AppStyles.appBarTitleSize)),
        automaticallyImplyLeading: !_isChecking,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppStyles.screenHorizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_isChecking || (widget.pairingCode != null && _loggedInUserJid == null) || (widget.initiallyAlreadyConnected && _loggedInUserJid == null))
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              SizedBox(height: AppStyles.largeSpacing),
              Text(
                _statusMessage, 
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: AppStyles.bodyTextSize),
              ),
              SizedBox(height: AppStyles.largeSpacing * 2),
              if (!_isChecking && _loggedInUserJid == null) 
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _statusMessage = appLocalizations.retryingConnection; 
                      });
                    }
                    _startPolling();
                  },
                  child: Text(appLocalizations.retryConnectionButton), 
                ),
            ],
          ),
        ),
      ),
    );
  }
}
