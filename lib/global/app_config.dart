class AppConfig {
  static const String editionId = "1143";
  static const String eventId = "189";
  static const String apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7";

  static const String baseUrl = "https://buzzevents.co";

  static const String version = "1.0.1+4";

  static const String registerUrl = "https://www.emecexpo.com/fr/tickets/";

  static const String logoBaseUrl = "$baseUrl/uploads/";

  static String get appSettingsUrl => "$baseUrl/api/events/$eventId/app-settings";

  static String get loginUrl => "$baseUrl/api/login";
}