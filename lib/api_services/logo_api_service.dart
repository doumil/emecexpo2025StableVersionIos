// lib/api_services/logo_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// 💡 إستيراد الـ Config الجلوبال الموحد
import 'package:emecexpo/global/app_config.dart';

class LogoApiService {
  // 🔗 1. تعويض الـ Event URL بـ شكل ديناميكي كيمشي لـ 1230 ديريكت
  static final String _eventApiUrl = '${AppConfig.baseUrl}/api/event/${AppConfig.eventId}';

  // 🖼️ 2. الـ Base URL ديال التصاور مربوط بـ الـ Base URL الجلوبال
  static final String _imageBaseUrl = '${AppConfig.baseUrl}/uploads/';

  /// Fetches the logo URL from the API event data.
  Future<String?> fetchLogoUrl() async {
    try {
      print('DEBUG: [LogoApiService] Fetching from: $_eventApiUrl');
      final response = await http.get(Uri.parse(_eventApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse['data'] is List &&
            jsonResponse['data'].isNotEmpty) {

          final eventData = jsonResponse['data'][0];

          // Check for the logo field, which holds the filename
          if (eventData['logo'] is String) {
            final String logoFilename = eventData['logo'];

            // Construct the full URL using the dynamic base path
            final String fullLogoUrl = '$_imageBaseUrl$logoFilename';
            print('✅ [LogoApiService] Logo URL built: $fullLogoUrl');
            return fullLogoUrl;
          }
        }
        return null;
      } else {
        print('Failed to load event data. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching logo data: $e');
      return null;
    }
  }
}