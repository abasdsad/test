// File: lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Define a type for the success callback
typedef OnSuccessCallback<T> = void Function(T data);
// Define a type for the error callback
typedef OnErrorCallback = void Function(String errorMessage, int? statusCode);

class ApiService {
  // Base URL for your Baileys server
  // For local development, if your Flutter app is running on an emulator/device
  // and your Node.js server is on your computer, use:
  // - Android Emulator: 'http://10.0.2.2:3000'
  // - iOS Simulator/Device (if server on same Wi-Fi): Your computer's local IP (e.g., 'http://192.168.1.X:3000')
  // - Web: 'http://localhost:3000' (if server is also on localhost)
  // Ensure your Node.js server is accessible from where your Flutter app is running.
  static const String _baseUrl = 'http://localhost:3000'; // ADJUST THIS FOR YOUR SETUP

  Future<void> sendRequest<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    required OnSuccessCallback<T> onSuccess,
    required OnErrorCallback onError,
    T Function(dynamic json)?fromJson, // Optional: for converting JSON to a specific type
  }) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    http.Response response;

    // Default headers
    Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8', // Corrected charset
      // Add any other common headers, like an API key if needed later
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    try {
      String? requestBodyJson;
      if (body != null) {
        requestBodyJson = jsonEncode(body);
      }

      switch (method) {
        case HttpMethod.get:
          response = await http.get(url, headers: defaultHeaders);
          break;
        case HttpMethod.post:
          response = await http.post(url, headers: defaultHeaders, body: requestBodyJson);
          break;
        case HttpMethod.put:
          response = await http.put(url, headers: defaultHeaders, body: requestBodyJson);
          break;
        case HttpMethod.delete:
          response = await http.delete(url, headers: defaultHeaders);
          break;
        // Add other methods like PATCH if needed
      }

      _handleResponse<T>(response, onSuccess, onError, fromJson); // Pass generic type T

    } on SocketException {
      onError('No Internet connection or server not reachable.', null);
    } on HttpException {
      onError('Couldn\'t find the resource.', null);
    } on FormatException {
      // This might occur if jsonEncode fails or jsonDecode fails.
      // jsonDecode failure is handled in _handleResponse.
      onError('Bad request/response format.', null);
    } catch (e) {
      onError('An unexpected error occurred: ${e.toString()}', null);
    }
  }

  void _handleResponse<T>( // Ensure T is passed here
    http.Response response,
    OnSuccessCallback<T> onSuccess,
    OnErrorCallback onError,
    T Function(dynamic json)? fromJson,
  ) {
    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    print('API Response Status Code: $statusCode');
    print('API Response Body: $responseBody');

    if (statusCode >= 200 && statusCode < 300) {
      try {
        dynamic jsonData = jsonDecode(responseBody);
        if (fromJson != null) {
          onSuccess(fromJson(jsonData));
        } else {
          // If fromJson is not provided, attempt to cast jsonData to T.
          // This works if T is dynamic, Map<String, dynamic>, List<dynamic>,
          // or a primitive type that jsonDecode might return (String, int, double, bool).
          if (jsonData is T) { // Check if jsonData is already of type T
            onSuccess(jsonData);
          } else {
            // If jsonData is not directly T, but T might be a supertype (like dynamic)
            // or if a cast is expected to work (e.g. Map to Map<String, dynamic> if T is that)
            try {
              onSuccess(jsonData as T);
            } catch (e) {
              // This catch block is important if T is a specific complex type
              // but no fromJson was provided, and jsonData isn't directly assignable/castable.
              print('ApiService Warning: fromJson is null and direct cast to $T failed. '
                  'Consider providing a fromJson converter for complex types. Error: $e');
              // Depending on strictness, you might call onError or still try to pass jsonData if T is dynamic
              if (T.toString() == 'dynamic') { // A less strict check for dynamic
                 onSuccess(jsonData);
              } else {
                onError(
                  'Type mismatch: Cannot assign response to type $T without a fromJson converter or if cast fails. Response was: $jsonData',
                  statusCode,
                );
              }
            }
          }
        }
      } catch (e) {
        onError('Error parsing JSON response: ${e.toString()}', statusCode);
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        // Try to parse error message from server response
        Map<String, dynamic> errorData = jsonDecode(responseBody);
        if (errorData.containsKey('message') && errorData['message'] is String) {
          errorMessage = errorData['message'];
        }
      } catch (e) {
        // If error response is not JSON or doesn't have 'message', use a generic one
        print('Could not parse error response as JSON: $e');
        if (responseBody.isNotEmpty) {
          errorMessage = responseBody; // Use raw body if not JSON
        }
      }
      onError(errorMessage, statusCode);
    }
  }
}

// Enum for HTTP methods
enum HttpMethod {
  get,
  post,
  put,
  delete,
}
