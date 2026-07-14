import 'package:flutter/material.dart';

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color blackColor;
  final Color whiteColor;
  final Color redColor;
  final String appTitle;
  final String bannerUrl;
  final String logoWhiteUrl;

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blackColor,
    required this.whiteColor,
    required this.redColor,
    required this.appTitle,
    required this.bannerUrl,
    required this.logoWhiteUrl,
  });

  // --- Getters الذكية للصور ---

  // كترجع ImageProvider للبانر
  ImageProvider get bannerImage {
    if (bannerUrl.contains('http')) {
      return NetworkImage(bannerUrl);
    }
    return AssetImage(bannerUrl);
  }

  // كترجع ImageProvider للوغو
  ImageProvider get logoImage {
    if (logoWhiteUrl.contains('http')) {
      return NetworkImage(logoWhiteUrl);
    }
    return AssetImage(logoWhiteUrl);
  }

  // --- Factory و الـ Logic ديال التحويل ---

  factory AppThemeData.fromApi(Map<String, dynamic>? json) {
    if (json == null) return defaultTheme();

    Color _parseColorValue(Map<String, dynamic>? colorData, {Color defaultColor = Colors.black}) {
      if (colorData != null && colorData['value'] != null) {
        try {
          String hex = colorData['value'].toString().replaceFirst('#', '');
          // التأكد من أن اللون بـ format صحيح 0xFF...
          if (hex.startsWith('0x')) return Color(int.parse(hex));
          if (hex.length == 6) hex = 'ff$hex';
          return Color(int.parse(hex, radix: 16));
        } catch (_) { return defaultColor; }
      }
      return defaultColor;
    }

    String _parseStringValue(dynamic data, {required String defaultValue}) {
      if (data == null) return defaultValue;
      if (data is Map && data['value'] != null) {
        return data['value'].toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return defaultValue;
    }

    return AppThemeData(
      primaryColor: _parseColorValue(json['primary_color'] as Map<String, dynamic>?),
      secondaryColor: _parseColorValue(json['secondary_color'] as Map<String, dynamic>?),
      blackColor: _parseColorValue(json['black_color'] as Map<String, dynamic>?),
      whiteColor: _parseColorValue(json['white_color'] as Map<String, dynamic>?),
      redColor: _parseColorValue(json['reed_color'] as Map<String, dynamic>?),
      appTitle: _parseStringValue(json['app_title'], defaultValue: "EMEC EXPO"),
      bannerUrl: _parseStringValue(json['banner_url'], defaultValue: 'assets/logo15.png'),
      logoWhiteUrl: _parseStringValue(json['logo_white_url'], defaultValue: 'assets/logo15.png'),
    );
  }

  static AppThemeData defaultTheme() {
    return AppThemeData(
      primaryColor: const Color(0xff50134f),
      secondaryColor: const Color(0xff00C1C1),
      blackColor: Colors.black,
      whiteColor: Colors.white,
      redColor: Colors.red,
      appTitle: "EMEC EXPO",
      bannerUrl: 'assets/logo15.png',
      logoWhiteUrl: 'assets/EMEC-LOGO.png',
    );
  }
}