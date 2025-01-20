import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../register&login/login.dart';


// AuthService class
class AuthService {
  final String baseUrl = 'https://bilalsas.pythonanywhere.com/user/signup/';

// Method for sending OTP
  Future<Map<String, dynamic>> sendOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('https://bilalsas.pythonanywhere.com/user/send/otp/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('OTP sent successfully: $responseData'); // Debugging line
      return responseData;
    } else {
      print('Failed to send OTP: ${response.body}'); // Debugging line
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

// Sign-Up Method (Updated)
  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String nationalIdNumber,
    BuildContext? context,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'national_id_number': nationalIdNumber,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

// Automatically send OTP after successful registration
      try {
        await sendOtp(email: email);
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up successful! OTP sent to your email.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up successful, but failed to send OTP.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      return responseData;
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account already registered with this email.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('رقم هاتف غير صالح');
    } else {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

// refresh token--------------------------------------------------

  Future<String?> refreshToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      return null; // Handle refresh token not found
    }

    final response = await http.post(
      Uri.parse('https://bilalsas.pythonanywhere.com/user/token/refresh/'),
      // Correct endpoint URL
      body: {'refresh': refreshToken},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final newAccessToken = responseData['access']; // Assuming 'access' key in response
      await prefs.setString('access_token', newAccessToken);
      return newAccessToken;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'حدث خطأ أثناء تحديث الرمز المميز. يرجى تسجيل الدخول مرة أخرى.'), // Arabic error message
        ),
      );
      // Handle refresh token error (e.g., invalid refresh token)
      return null;
    }
  }

// Logout------------------------------------------------------
  Future<void> logout(BuildContext context) async {
    try {
      // Retrieve tokens
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken == null || refreshToken == null) {
        _showError(context, 'Tokens not found. Please log in again.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
        return;
      }

      // Create request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://bilalsas.pythonanywhere.com/user/logout/'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Content-Type'] = 'application/json';
      request.fields['refresh_token'] = refreshToken;

      // Send the request
      final response = await request.send();

      print('Response Status Code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');

      if (response.statusCode == 205) {
        // Logout successful
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');

        _showSuccess(context, 'Logout successful.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      } else {
        print('Failed Response [${response.statusCode}]: $responseBody');
        _showError(context, 'Failed to logout. Please try again.');
      }
    } catch (e) {
      print('Error during logout: $e');
      _showError(context, 'An error occurred during logout.');
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }



//password reset send otp ------------------------------------------------------------------------
  Future<bool> sendPasswordResetOtp(String email) async {
    try {
      final url = Uri.parse('https://bilalsas.pythonanywhere.com/user/password/reset/send/otp/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // OTP sent successfully
      } else {
        print('Failed to send OTP: ${response.body}');
        return false; // Failed to send OTP
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }
//password reset verfy otp ------------------------------------------------------------------------
  Future<bool> verifyOtpReset({required String email, required String otp}) async {
    try {
      final url = Uri.parse('https://bilalsas.pythonanywhere.com/user/password/reset/verify/otp/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // OTP verified successfully
      } else {
        print('OTP verification failed: ${response.body}');
        return false; // OTP verification failed
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
// new password page------------------------------------------------------------------------
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String token,
  }) async {
    try {
      final url = Uri.parse('https://bilalsas.pythonanywhere.com/user/password/reset/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'new_password': newPassword,
          'token': token,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Password reset successful
      } else {
        print('Password reset failed: ${response.body}');
        return false; // Password reset failed
      }
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }


  final String clientId = "BUMHOIcamdicheujaihUbP4P2bqZLPK1U9Qjpr3w";

  /// Convert Google Token to Backend Token
  Future<Map<String, String>?> convertGoogleToken(String googleToken) async {
    final url = Uri.parse('https://bilalsas.pythonanywhere.com/auth/convert-token/');
    try {
      print('Starting Google token conversion...');
      print('Google Token: $googleToken');
      print('Full URL: $url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "grant_type": "convert-token",
          "backend": "google-oauth2",
          "client_id": "BUMHOIcamdicheujaihUbP4P2bqZLPK1U9Qjpr3w",
          "token": googleToken,
        }),
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'] as String;
        final refreshToken = responseData['refresh_token'] as String;

        // Save tokens locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        return {
          'access_token': accessToken,
          'refresh_token': refreshToken,
        };
      } else {
        print('Failed to convert Google token: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error during Google token conversion: $error');

      return null;

    }
  }


  /// Refresh Backend Token
  Future<String?> refreshGoogleAccessToken(String refreshToken) async {
    final url = Uri.parse('https://bilalsas.pythonanywhere.com/auth/token/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "grant_type": "refresh-token",
          "backend": "google-oauth2",
          "client_id": clientId,
          "token": refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access_token'] as String;

        // Save the new access token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newAccessToken);

        return newAccessToken;
      } else {
        print('Failed to refresh token: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error refreshing token: $error');
      return null;
    }
  }




}