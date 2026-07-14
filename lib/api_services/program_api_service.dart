// lib/api_services/program_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// 💡 إستيراد الـ Config الجلوبال الموحد بـ الـ Package Import المضمون
import 'package:emecexpo/global/app_config.dart';
import 'package:emecexpo/model/program_model.dart';

class ProgramApiService {
  // 🔗 تعويض الـ URL بـ شكل ديناميكي كيقرا الـ Base URL والـ Edition ID من الـ Config ديريكت
  static final String _apiUrl = '${AppConfig.baseUrl}/api/edition/${AppConfig.editionId}/program';

  Future<ProgramDataModel> fetchProgramDetails() async {
    final url = Uri.parse(_apiUrl);
    try {
      print("🔍 [ProgramApiService] Fetching program from: $_apiUrl");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResponse['success'] == true && jsonResponse['data'] is Map<String, dynamic>) {
          // 💡 Safety Enhancement: Ensure 'data' is passed as a Map<String, dynamic>
          final Map<String, dynamic> data = jsonResponse['data'] as Map<String, dynamic>;

          return ProgramDataModel.fromJson(data);
        } else {
          // Handle cases where 'success' is false or 'data' is missing/not a map
          throw Exception('API response succeeded but program data is missing or invalid. Success: ${jsonResponse['success']}, Data Type: ${jsonResponse['data']?.runtimeType}');
        }
      } else {
        throw Exception('Failed to load program details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // For debugging, print the exact error
      print("Program API Error: $e");
      // Re-throw a more user-friendly error message
      throw Exception('Network or parsing error fetching program: $e');
    }
  }
}