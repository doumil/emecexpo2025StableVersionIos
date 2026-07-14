// lib/api_services/event_contact_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/global/app_config.dart';
import '../model/event_contact_model.dart';

class EventContactApiService {
  static final String _eventUrl = '${AppConfig.baseUrl}/api/event/${AppConfig.eventId}';
  static final String _settingsUrl = '${AppConfig.baseUrl}/api/events/${AppConfig.eventId}/app-settings';

  Future<EventContactModel> fetchEventDetails() async {
    try {
      print('DEBUG: [EventContactApiService] Fetching from both APIs parallelly...');

      // 🔄 طلب البيانات من الـ 2 APIs ف نفس الوقت
      final responses = await Future.wait([
        http.get(Uri.parse(_eventUrl)),
        http.get(Uri.parse(_settingsUrl)),
      ]);

      final eventResponse = responses[0];
      final settingsResponse = responses[1];

      if (eventResponse.statusCode == 200) {
        // 1. قراءة الـ JSON الأصلي كـ Map قابل للتعديل
        final Map<String, dynamic> eventJson = json.decode(eventResponse.body) as Map<String, dynamic>;

        if (eventJson['success'] == true && eventJson['data'] is List && eventJson['data'].isNotEmpty) {

          // ⚙️ 2. إذا نجح الـ Request ديال الـ app-settings، غادي نعدلو الـ JSON بيدنا أولاً
          if (settingsResponse.statusCode == 200) {
            final Map<String, dynamic> settingsJson = json.decode(settingsResponse.body) as Map<String, dynamic>;

            // تحديد مكان الـ organizer داخل الـ JSON (غالباً كيكون ف أول عنصر ف الـ list)
            var firstEvent = eventJson['data'][0];
            if (firstEvent['organizer'] != null) {

              // تعويض الهاتف الجديد ف الـ JSON
              if (settingsJson['support_phone'] != null && settingsJson['support_phone']['value'] != null) {
                firstEvent['organizer']['phone'] = settingsJson['support_phone']['value'].toString();
              }

              // تعويض الإيميل الجديد ف الـ JSON
              if (settingsJson['contact_email'] != null && settingsJson['contact_email']['value'] != null) {
                firstEvent['organizer']['email'] = settingsJson['contact_email']['value'].toString();
              }
            }
          }

          // 📦 3. دابا كنصيفطو الـ JSON المعدل للـ Model وهو هاني بلا مشاكل د final
          return EventContactModel.fromJson(eventJson);
        } else {
          throw Exception('Event data is missing from API.');
        }
      } else {
        throw Exception('Failed to load event details. Status Code: ${eventResponse.statusCode}');
      }
    } catch (e) {
      print('DEBUG: [EventContactApiService] Error: $e');
      throw Exception('Network or parsing error: $e');
    }
  }
}