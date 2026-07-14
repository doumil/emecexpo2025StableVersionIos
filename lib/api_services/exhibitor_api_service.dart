// lib/api_services/exhibitor_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// 💡 إستيراد الـ Config الجلوبال بـ الطريقة الاحترافية الموحدة
import 'package:emecexpo/global/app_config.dart';
import 'package:emecexpo/model/exhibitors_model.dart';

class ExhibitorApiService {
  // 🔗 تعويض الـ URL بـ شكل ديناميكي باستعمال الـ Base URL والـ Edition ID من الـ Config
  static final String _apiUrl = "${AppConfig.baseUrl}/api/edition/${AppConfig.editionId}/exposants";

  Future<List<ExhibitorsClass>> getExhibitors() async {
    try {
      print('DEBUG: [ExhibitorApiService] Fetching exhibitors from: $_apiUrl');
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if API call succeeded and the 'exposants' list exists within 'data'
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['exposants'] is List) {

          final List<dynamic> exposantsJson = jsonResponse['data']['exposants'];

          // Map the JSON list to a list of ExhibitorsClass objects
          return exposantsJson.map((json) => ExhibitorsClass.fromJson(json)).toList();
        } else {
          throw Exception("API call succeeded but exposant list is missing or invalid in JSON structure.");
        }
      } else {
        throw Exception('Failed to load exhibitors: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exhibitors: $e');
      throw Exception('Network Error or Data Parsing Failed: $e');
    }
  }
}