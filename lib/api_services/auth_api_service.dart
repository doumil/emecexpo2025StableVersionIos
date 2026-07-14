// lib/services/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/model/user_model.dart';
import '../global/app_config.dart';
// 💡 إستيراد الـ Config الجلوبال

class AuthApiService {
  // 🌐 1. تعويض الروابط والمتغيرات بـ الجلوبال ديريكت
  static final String _baseUrl = "${AppConfig.baseUrl}/api";
  static final String _editionId = AppConfig.editionId; // 💡 غاتقرأ 1133 الديناميكية
  static final String _apiKey = AppConfig.apiKey;       // 💡 غاتقرأ الـ Key الموحد

  // -------------------------------------------------------------------------
  // STEP 1: Send Verification Code to Gmail
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/event/edition/$_editionId/sendVerificationCode/AppMobile');

    try {
      print('DEBUG: Step 1 Request to: $uri');
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
      print('DEBUG: Step 1 Exception: $e');
      return {'success': false, 'message': 'Network error in Step 1.'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 2: Verify Code -> Get Small Token ($2y$12...)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final Uri uri = Uri.parse('$_baseUrl/verifyVerificationCode/AppMobile');

    try {
      print('DEBUG: Step 2 Request to: $uri');
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
          'editionId': int.tryParse(_editionId),
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        String smallToken = responseData['user']['token'];
        String qrCodeXml = responseData['order'] != null ? responseData['order']['qrcode'] : "";

        print("DEBUG: Step 2 Success. Small Token: $smallToken");

        return await _getFinalFullToken(smallToken, responseData['user'], qrCodeXml);
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid code.',
        };
      }
    } catch (e) {
      print('DEBUG: Step 2 Exception: $e');
      return {'success': false, 'message': 'Verification failed (Step 2).'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 3: Exchange Small Token for Full Token (JWT) via GET
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> _getFinalFullToken(String smallToken, Map<String, dynamic> userMap, String qrCode) async {
    final String encodedToken = Uri.encodeComponent(smallToken.trim());

    // 💡 عودناها بـ AppConfig.baseUrl باش تحيد www ويتحسن الأداء والموثوقية
    final String url = '${AppConfig.baseUrl}/api/login/link?tokenus=$encodedToken';
    final Uri uri = Uri.parse(url);

    try {
      print("DEBUG: Requesting Step 3 (GET) -> $url");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
      );

      print("DEBUG: Step 3 Response Code: ${response.statusCode}");
      print("DEBUG: Step 3 Response Body: ${response.body}");

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

          return {
            'success': true,
            'user': user,
            'token': fullJwtToken,
          };
        }
      }

      return {
        'success': false,
        'message': 'Full token exchange failed (Error ${response.statusCode}).',
      };
    } catch (e) {
      print("DEBUG: Step 3 Exception: $e");
      return {'success': false, 'message': 'Connection error in final step.'};
    }
  }

  Future<Map<String, dynamic>> forgetPassword(String email) async {
    return await sendVerificationCode(email);
  }
}