import 'package:flutter/material.dart';
import 'package:emecexpo/model/app_theme_data.dart';
import 'package:emecexpo/providers/app_config_provider.dart';

class ThemeProvider with ChangeNotifier {
  // كنبداو بالـ Default Theme
  AppThemeData _currentTheme = AppThemeData.defaultTheme();

  AppThemeData get currentTheme => _currentTheme;

  /// هاد الميثود كتاخد الـ Data الخام من AppConfigProvider وكتطبق الـ Theme
  void updateThemeFromConfig(AppConfigProvider configProvider) {
    final Map<String, dynamic>? data = configProvider.rawSettings;

    if (data != null) {
      _currentTheme = AppThemeData.fromApi(data);
      notifyListeners();
      debugPrint("✅ [ThemeProvider] Theme updated successfully from Config.");
    }
  }

  /// في حالة بغيتي دير reset للـ theme
  void resetToDefault() {
    _currentTheme = AppThemeData.defaultTheme();
    notifyListeners();
  }
}