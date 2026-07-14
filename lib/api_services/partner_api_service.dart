// lib/api_services/partner_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// 💡 إستيراد الـ Config الجلوبال الموحد
import 'package:emecexpo/global/app_config.dart';
import 'package:emecexpo/model/partner_model.dart';

class PartnerApiService {
  // 🔗 تعويض الـ الدومين المجمّد بـ الـ Base URL الديناميكي من الـ Config
  static final String _partnerUrl = '${AppConfig.baseUrl}/api/partner';

  Future<List<PartnerClass>> getPartners() async {
    debugPrint("🔍 [PartnerApiService] Attempting to fetch partners from API: $_partnerUrl");
    try {
      final response = await http.get(Uri.parse(_partnerUrl));

      if (response.statusCode == 200) {
        debugPrint("✅ [PartnerApiService] Partners API request successful (Status 200).");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<dynamic> dataList = jsonData['data'];
          return dataList.map((json) => PartnerClass.fromJson(json)).toList();
        } else {
          debugPrint("⚠️ [PartnerApiService] Response is missing the 'data' key or data is not a list.");
          return [];
        }
      } else {
        debugPrint("⚠️ [PartnerApiService] Request failed with status code: ${response.statusCode}");
        throw HttpException('Failed to load partners data. Status Code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint("❌ [PartnerApiService] Network error: Could not connect to partners host.");
      return [];
    } catch (e) {
      debugPrint("❌ [PartnerApiService] An unexpected error occurred: $e");
      rethrow;
    }
  }
}