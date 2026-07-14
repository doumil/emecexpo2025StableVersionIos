import 'package:flutter/material.dart';
import 'package:emecexpo/providers/app_config_provider.dart';

class CardItem {
  final String title;
  final String iconName;
  final String dataValue;
  final bool isCustomCard;
  final String apiKey;

  CardItem({
    required this.title,
    required this.iconName,
    required this.dataValue,
    this.isCustomCard = false,
    required this.apiKey,
  });

  CardItem copyWith({String? dataValue}) {
    return CardItem(
      title: this.title,
      iconName: this.iconName,
      dataValue: dataValue ?? this.dataValue,
      isCustomCard: this.isCustomCard,
      apiKey: this.apiKey,
    );
  }
}

class HomeProvider with ChangeNotifier {
  List<CardItem> _cards = [];
  List<CardItem> get cards => _cards;

  HomeProvider() {
    _cards = _getDefaultCards();
  }

  void updateCardsFromConfig(AppConfigProvider configProvider) {
    final Map<String, dynamic>? data = configProvider.rawSettings;
    if (data == null) return;

    String checkState(String dataKey) {
      // إذا كنا نتحقق من My Agenda، نربطها بحالة الـ badge
      String finalKey = (dataKey == 'my_agenda') ? 'badge' : dataKey;

      dynamic value = data[finalKey];
      if (value == null) {
        final lowerKey = finalKey.toLowerCase();
        final exactKey = data.keys.firstWhere((k) => k.toLowerCase() == lowerKey, orElse: () => '');
        if (exactKey.isNotEmpty) value = data[exactKey];
      }

      if (value == null) return '1';

      if (value is bool) {
        return value ? '1' : '0';
      }
      if (value is Map && value.containsKey('enabled')) {
        return value['enabled'] == true ? '1' : '0';
      }
      if (value == 0 || value == '0' || value == false) {
        return '0';
      }
      return '1';
    }

    _cards = _getDefaultCards().map((card) {
      final String status = checkState(card.apiKey);
      return card.copyWith(dataValue: status);
    }).toList();

    notifyListeners();
  }

  List<CardItem> _getDefaultCards() {
    return [
      CardItem(title: 'My Badge', iconName: 'qr_code_scanner', dataValue: '1', isCustomCard: true, apiKey: 'badge'),
      CardItem(title: 'Floor Plan', iconName: 'location_on_outlined', dataValue: '1', apiKey: 'floor_plan'),
      CardItem(title: 'Program', iconName: 'event_note', dataValue: '1', apiKey: 'program'), // تابعة لـ program ف الـ API
      CardItem(title: 'My Agenda', iconName: 'calendar_today_outlined', dataValue: '1', apiKey: 'my_agenda'), // تابعة للـ badge/user حسابيا
      CardItem(title: 'Exhibitors', iconName: 'store_mall_directory_outlined', dataValue: '1', apiKey: 'exhibitors'),
      CardItem(title: 'Conferences', iconName: 'speaker_notes_outlined', dataValue: '1', apiKey: 'speakers'),
      CardItem(title: 'Institutional\nPartners', iconName: 'handshake_outlined', dataValue: '1', apiKey: 'partners'),
      CardItem(title: 'Sponsors', iconName: 'favorite_outline', dataValue: '1', apiKey: 'sponsors'),
    ];
  }
}