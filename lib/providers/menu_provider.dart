import 'package:flutter/material.dart';
import 'package:emecexpo/providers/app_config_provider.dart';
import 'package:emecexpo/constants.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final bool isCustomCard;

  MenuItem({
    required this.title,
    required this.icon,
    required this.section,
    this.isCustomCard = false,
  });
}

class MenuConfig {
  final bool floorPlan;
  final bool exhibitors;
  final bool speakers;
  final bool program; // خاص بـ Program Screen
  final bool sponsors;
  final bool partners;
  final bool badge;
  final bool networking;

  MenuConfig({
    this.floorPlan = true,
    this.exhibitors = true,
    this.speakers = true,
    this.program = true,
    this.sponsors = true,
    this.partners = true,
    this.badge = true,
    this.networking = true,
  });

  factory MenuConfig.fromRawData(Map<String, dynamic> data) {
    bool getValue(String key) {
      dynamic value = data[key];
      if (value == null) {
        final lowerKey = key.toLowerCase();
        final exactKey = data.keys.firstWhere((k) => k.toLowerCase() == lowerKey, orElse: () => '');
        if (exactKey.isNotEmpty) value = data[exactKey];
      }

      if (value == null) return true;
      if (value is bool) return value;
      if (value is Map && value.containsKey('enabled')) {
        return value['enabled'] == true;
      }
      return value.toString() == '1' || value.toString().toLowerCase() == 'true';
    }

    return MenuConfig(
      floorPlan: getValue('floor_plan'),
      exhibitors: getValue('exhibitors'),
      speakers: getValue('speakers'),
      program: getValue('program'), // كيقرا الـ bool ديريكت من السيرفر
      sponsors: getValue('sponsors'),
      partners: getValue('partners'),
      badge: getValue('badge'),
      networking: getValue('networking'),
    );
  }
}

class MenuProvider with ChangeNotifier {
  MenuConfig? _menuConfig;
  MenuConfig? get menuConfig => _menuConfig;

  List<MenuItem> _visibleItems = [];
  List<MenuItem> get visibleItems => _visibleItems;

  void updateMenuFromConfig(AppConfigProvider configProvider) {
    final Map<String, dynamic>? data = configProvider.rawSettings;
    if (data != null) {
      _menuConfig = MenuConfig.fromRawData(data);
      _generateVisibleItems();
      notifyListeners();
    }
  }

  void _generateVisibleItems() {
    if (_menuConfig == null) return;

    // 🟩 هنا تم الفصل: تفك الارتباط وبقت كل وحدة تابعة للـ الـ Config ديالها
    final List<Map<String, dynamic>> allItems = [
      {'title': 'My Badge', 'icon': Icons.qr_code_scanner, 'section': DrawerSections.myBadge, 'status': _menuConfig!.badge, 'custom': true},
      {'title': 'Floor Plan', 'icon': Icons.location_on_outlined, 'section': DrawerSections.eFP, 'status': _menuConfig!.floorPlan},
      {'title': 'Program', 'icon': Icons.event_note, 'section': DrawerSections.program, 'status': _menuConfig!.program}, // شاشة الـ البروݣرام العام
      {'title': 'My Agenda', 'icon': Icons.calendar_today_outlined, 'section': DrawerSections.myAgenda, 'status': _menuConfig!.badge}, // لـجندة الشخصية (مربوطة بالـ badge/الأكونت)
      {'title': 'Exhibitors', 'icon': Icons.store_mall_directory_outlined, 'section': DrawerSections.exhibitors, 'status': _menuConfig!.exhibitors},
      {'title': 'Networking', 'icon': Icons.people_outline, 'section': DrawerSections.networking, 'status': _menuConfig!.networking},
      {'title': 'Speakers', 'icon': Icons.person_outline, 'section': DrawerSections.speakers, 'status': _menuConfig!.speakers},
      {'title': 'Institutional\nPartners', 'icon': Icons.handshake_outlined, 'section': DrawerSections.partners, 'status': _menuConfig!.partners},
      {'title': 'Sponsors', 'icon': Icons.favorite_outline, 'section': DrawerSections.sponsors, 'status': _menuConfig!.sponsors},
    ];

    _visibleItems = allItems
        .where((item) => item['status'] == true)
        .map((item) => MenuItem(
      title: item['title'] as String,
      icon: item['icon'] as IconData,
      section: item['section'] as DrawerSections,
      isCustomCard: item['custom'] == true,
    ))
        .toList();
  }
}