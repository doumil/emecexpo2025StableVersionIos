import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/model/user_model.dart';

class AuthApiService {
  static const String _baseUrl = "https://www.buzzevents.co/api";
  static const int _editionId = 1143;
  static const String _apiKey = '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7';

  // -------------------------------------------------------------------------
  // STEP 1: Send Verification Code to Gmail
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/event/edition/$_editionId/sendVerificationCode/AppMobile');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Code sent successfully.',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send code.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error in Step 1.'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 2: Verify Code -> Detection for Apple Review
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final Uri uri = Uri.parse('$_baseUrl/verifyVerificationCode/AppMobile');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
        body: jsonEncode({
          'email': email,
          'verification_code': code,
          'editionId': _editionId,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {

        // 🍎 LOGIC FOR APPLE REVIEW EMAIL
        if (email.trim().toLowerCase() == "review@buzzevents.app") {
          print("DEBUG: Apple Review Account Detected. Processing directly.");
          return await _handleAppleReviewLogin(responseData);
        }

        // Standard Login Path
        String smallToken = responseData['user']['token'] ?? "";
        String qrCodeXml = responseData['order'] != null ? responseData['order']['qrcode'] ?? "" : "";

        print("DEBUG: Step 2 Success. Standard Path.");
        return await _getFinalFullToken(smallToken, responseData['user'], qrCodeXml);
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid code.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Verification failed (Step 2). Error: $e'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 3: Exchange Small Token for Full Token (Standard Path)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> _getFinalFullToken(String smallToken, Map<String, dynamic> userMap, String qrCode) async {
    final String encodedToken = Uri.encodeComponent(smallToken.trim());
    final String url = 'https://buzzevents.co/api/login/link?tokenus=$encodedToken';
    final Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json', 'X-Api-Key': _apiKey});

      if (response.statusCode == 200) {
        final Map<String, dynamic> linkData = json.decode(response.body);
        if (linkData.containsKey('token')) {
          String fullJwtToken = linkData['token'];
          userMap['token'] = fullJwtToken;

          final User user = User.fromJson(userMap);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', fullJwtToken);
          await prefs.setString('currentUserJson', jsonEncode(userMap));
          await prefs.setString('qrCodeXml', qrCode);

          return {'success': true, 'user': user, 'token': fullJwtToken};
        }
      }
      return {'success': false, 'message': 'Full token exchange failed.'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error in final step.'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 4: Handle Apple Review Data Directly (No remote call)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> _handleAppleReviewLogin(Map<String, dynamic> responseData) async {
    try {
      // Use the static token provided in the response
      String appleToken = responseData['token'] ?? "apple-review-token";
      Map<String, dynamic> userMap = responseData['user'];

      // Update the user map with the token so User.fromJson works correctly
      userMap['token'] = appleToken;

      final User user = User.fromJson(userMap);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', appleToken);
      await prefs.setString('currentUserJson', jsonEncode(userMap));

      // For Apple Review, the order id is 0 and hashed_order_id is "apple-test-order"
      // We store a placeholder or empty string for QR code
      await prefs.setString('qrCodeXml', "");

      return {
        'success': true,
        'user': user,
        'token': appleToken,
      };
    } catch (e) {
      print("DEBUG: Error in Step 4: $e");
      return {'success': false, 'message': 'Local data processing failed.'};
    }
  }

  Future<Map<String, dynamic>> forgetPassword(String email) async {
    return await sendVerificationCode(email);
  }
}