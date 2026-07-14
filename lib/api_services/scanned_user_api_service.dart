// lib/api_services/scanned_user_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:emecexpo/global/app_config.dart';

class ScannedUserApiService {
  // Base URL built dynamically from global application configuration
  static final String _baseUrl = '${AppConfig.baseUrl}/api/user-by-order/';

  /// Fetches scanned user profile details using a unique QR hash identifier.
  Future<Map<String, dynamic>> getUserByQrHash(String qrHash) async {
    final url = Uri.parse('$_baseUrl$qrHash');
    debugPrint('[API Service] Attempting API call to: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        debugPrint('[API Service] Response Status 200. JSON Keys: ${responseJson.keys.join(', ')}');

        if (responseJson['success'] == true) {
          final Map<String, dynamic>? userData = responseJson['data'] as Map<String, dynamic>?;

          if (userData == null || userData.isEmpty) {
            debugPrint('[API Service] Success=true but "data" key is null or empty.');
            return {
              'success': false,
              'message': responseJson['message'] ?? 'User not found or data is empty.'
            };
          }

          return {
            'success': true,
            'userMap': userData,
          };
        } else {
          return {
            'success': false,
            'message': responseJson['message'] ?? 'Failed to retrieve user data.'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'API call failed with status code ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('[API Service] Exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}