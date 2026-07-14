// lib/api_services/speaker_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/global/app_config.dart';
import '../model/speakers_model.dart';

class SpeakerApiService {
  // Endpoints built dynamically using global application configuration
  static final String _baseUrl = "${AppConfig.baseUrl}/api/edition/${AppConfig.editionId}/speakers-with-sessions";

  // Base directory path for speaker image assets
  static final String imageBaseUrl = "${AppConfig.baseUrl}/uploads/";

  /// Fetches speakers and their associated sessions for the current event edition.
  Future<SpeakersDataModel> fetchSpeakersWithSessions() async {
    print("🔍 [SpeakerApiService] Fetching speakers from: $_baseUrl");
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      return SpeakersDataModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load speakers data. Status Code: ${response.statusCode}');
    }
  }
}