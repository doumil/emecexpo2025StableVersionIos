import 'package:flutter/material.dart';

class AppConfigModel {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final String appTitle;
  final String appDescription;
  final String contactEmail;
  final String supportPhone;
  final bool enableNotifications;
  final bool badgeEnabled;
  final bool sponsorsEnabled;
  final bool programEnabled;
  final bool speakersEnabled;
  final bool exhibitorsEnabled;

  AppConfigModel({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.appTitle,
    required this.appDescription,
    required this.contactEmail,
    required this.supportPhone,
    required this.enableNotifications,
    required this.badgeEnabled,
    required this.sponsorsEnabled,
    required this.programEnabled,
    required this.speakersEnabled,
    required this.exhibitorsEnabled,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لتحويل الألوان
    Color parseColor(String? colorString) {
      try {
        return Color(int.parse(colorString!.replaceFirst('0x', ''), radix: 16));
      } catch (e) {
        return Colors.blue; // لون افتراضي في حالة الخطأ
      }
    }

    final data = json['data'] as Map<String, dynamic>;

    return AppConfigModel(
      primaryColor: parseColor(data['primary_color']['value']),
      secondaryColor: parseColor(data['secondary_color']['value']),
      backgroundColor: parseColor(data['background_color']['value']),
      textColor: parseColor(data['text_color']['value']),
      appTitle: data['app_title']['value'] ?? 'EMEC EXPO',
      appDescription: data['app_description']['value'] ?? '',
      contactEmail: data['contact_email']['value'] ?? '',
      supportPhone: data['support_phone']['value'] ?? '',
      enableNotifications: data['enable_notifications'] ?? true,
      badgeEnabled: data['badge'] ?? true,
      sponsorsEnabled: data['sponsors'] ?? true,
      programEnabled: data['program'] ?? true,
      speakersEnabled: data['speakers'] ?? true,
      exhibitorsEnabled: data['exhibitors'] ?? true,
    );
  }
}