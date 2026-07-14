// lib/api_services/sponsor_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// 💡 Centralized global configuration import
import 'package:emecexpo/global/app_config.dart';
import 'package:emecexpo/model/sponsor_model.dart';

class SponsorApiService {
  // Dynamic endpoint URL using the centralized base path configuration
  static final String _sponsorUrl = '${AppConfig.baseUrl}/api/sponosors';

  /// Fetches the complete list of event sponsors from the remote API.
  Future<List<SponsorClass>> getSponsors() async {
    debugPrint("🔍 [SponsorApiService] Attempting to fetch sponsors from API: $_sponsorUrl");
    try {
      final response = await http.get(Uri.parse(_sponsorUrl));

      if (response.statusCode == 200) {
        debugPrint("✅ [SponsorApiService] Sponsors API request successful (Status 200).");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<dynamic> dataList = jsonData['data'];
          return dataList.map((json) => SponsorClass.fromJson(json)).toList();
        } else {
          debugPrint("⚠️ [SponsorApiService] Response is missing the 'data' key or data is not a list.");
          throw const FormatException("API response is missing the 'data' key or data is not a list.");
        }
      } else {
        debugPrint("⚠️ [SponsorApiService] Request failed with status code: ${response.statusCode}");
        throw HttpException('Failed to load sponsors data. Status Code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint("❌ [SponsorApiService] Network error: Could not connect to sponsors host.");
      throw const SocketException('No Internet connection to fetch sponsors.');
    } catch (e) {
      debugPrint("❌ [SponsorApiService] An unexpected error occurred: $e");
      rethrow;
    }
  }
}