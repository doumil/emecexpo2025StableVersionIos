// lib/api_services/networking_api_service.dart

import 'dart:convert';
import 'api_client.dart';
// 💡 إستيراد الـ Config الجلوبال الموحد
import 'package:emecexpo/global/app_config.dart';
import '../model/exposant_networking_model.dart';
import '../model/commerciaux_model.dart';

class NetworkingApiService {
  // 🆔 تعويض الرقم المجمّد بـ المتغير الديناميكي من الـ Config وتحويله لـ int
  static final int currentEditionId = int.tryParse(AppConfig.editionId) ?? 1133;

  /// Fetch Exhibitors
  Future<List<ExposantNetworking>> getNetworkingExhibitors(String userToken) async {
    try {
      ApiClient.setAccessToken(userToken);
      final response = await ApiClient.get('/networking/edition/$currentEditionId', requireAuth: true);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData.containsKey('exposants')) {
          List list = decodedData['exposants'];
          return list.map((item) => ExposantNetworking.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('DEBUG: [NetworkingApiService] getNetworkingExhibitors Error: $e');
      return [];
    }
  }

  /// Fetch Commercials
  Future<List<CommerciauxClass>> getCommerciaux(String userToken, int exposantId) async {
    try {
      ApiClient.setAccessToken(userToken);
      final String endpoint = '/networking/edition/$currentEditionId/exposant/$exposantId';
      final response = await ApiClient.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        List list = (decodedData is List) ? decodedData : (decodedData['commerciaux'] ?? []);
        return list.map((item) => CommerciauxClass.fromJson(item)).toList();
      }
      throw Exception("Server Error");
    } catch (e) {
      print('DEBUG: [NetworkingApiService] getCommerciaux Error: $e');
      throw Exception("Could not load commercials.");
    }
  }

  /// REAL BOOKING CALL
  /// Body settings: creneauid, startcreneau, endcreneau
  Future<bool> bookMeeting(String token, Creneau slot) async {
    try {
      ApiClient.setAccessToken(token);

      final Map<String, dynamic> body = {
        'creneauid': slot.id,
        'startcreneau': slot.debut,
        'endcreneau': slot.fin,
      };

      print("DEBUG: Final Booking Payload: $body");

      final response = await ApiClient.post(
        '/networking/creneau',
        body,
        requireAuth: true,
      );

      print("DEBUG: API Response Code: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("DEBUG: Booking Exception: $e");
      return false;
    }
  }
}