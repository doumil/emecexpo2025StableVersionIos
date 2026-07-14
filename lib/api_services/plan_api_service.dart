// lib/api_services/floor_plan_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// 💡 إستيراد الـ Config الجلوبال الموحد بـ الـ Package Import
import 'package:emecexpo/global/app_config.dart';

class FloorPlanApiService {
  // 🔗 تعويض الـ URL بـ شكل ديناميكي كيقرا الـ Base URL والـ Edition ID الجديد ديريكت
  static final String _apiUrl = '${AppConfig.baseUrl}/api/edition/${AppConfig.editionId}/plan';

  /// Fetches the floor plan image URL from the API.
  /// Returns the image URL string if successful, otherwise returns null.
  static Future<String?> getFloorPlanImageUrl() async {
    try {
      print("静态 [FloorPlanApiService] Fetching from: $_apiUrl");
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as Map<String, dynamic>?;

          if (data != null && data.containsKey('plan')) {
            final imageUrl = data['plan'] as String?;
            print("✅ [FloorPlanApiService] Floor Plan Image URL found: $imageUrl");
            return imageUrl;
          } else {
            print("API response success=true but 'data' or 'plan' field is missing.");
            return null;
          }
        } else {
          print("API reported success: false. Response: ${jsonResponse['message']}");
          return null;
        }
      } else {
        print("Failed to load floor plan data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching floor plan image URL: $e");
      return null;
    }
  }
}