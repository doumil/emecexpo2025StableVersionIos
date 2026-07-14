import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/global/app_config.dart';
import '../model/AppConfigModel.dart';

class AppConfigProvider with ChangeNotifier {
  AppConfigModel? _config;
  Map<String, dynamic>? _rawSettings;

  AppConfigModel? get config => _config;
  Map<String, dynamic>? get rawSettings => _rawSettings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initializeConfig() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('app_settings_cache_${AppConfig.eventId}');

    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        _rawSettings = decoded['data']; // كنخليو الـ rawSettings ديما شغال وخا يتفرقع الموديل
        _config = AppConfigModel.fromJson(decoded);
      } catch (e) {
        debugPrint("⚠️ Error parsing Model from cache (ignoring): $e");
      }
    }

    await fetchFromApi();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFromApi() async {
    try {
      debugPrint("Fetching config from: ${AppConfig.appSettingsUrl}");

      final response = await http.get(
        Uri.parse(AppConfig.appSettingsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        _rawSettings = jsonData['data']; // كنحفظو الداتا الخام فوراً باش نخدمو بيها ف الـ Providers ديريكت

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_settings_cache_${AppConfig.eventId}', json.encode(jsonData));

        try {
          _config = AppConfigModel.fromJson(jsonData);
        } catch (modelError) {
          // إيلا تفرقع الـ Model بسبب الـ DataType د السيرفر، الـ App غايكمل عادي بالـ rawSettings
          debugPrint("⚠️ [AppConfigModel] Crashed due to server types but bypassed: $modelError");
        }

        debugPrint("✅ Configuration synced.");
        notifyListeners();
      } else {
        debugPrint("Failed to fetch config: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching config from API: $e");
    }
  }
}