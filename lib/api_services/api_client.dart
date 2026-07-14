// lib/services/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../global/app_config.dart';

class ApiClient {
  // 🌐 1. الـ Base URL ولا كيجيب ديريكت من السورس مع زيادة /api
  static final String _baseUrl = '${AppConfig.baseUrl}/api';

  static String? _accessToken;

  // 🔑 2. الـ API Key ولا كايتجر ديريكت من بلاصتو ف الـ Config
  static final String _apiKey = AppConfig.apiKey;

  static void setAccessToken(String? token) {
    _accessToken = token;
  }

  static Map<String, String> getHeaders({bool requireAuth = false, String? authToken}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Api-Key': _apiKey, // 💡 غايقرا الـ Key الجديد
      // 🛡️ CRITICAL: This bypasses Nginx 403 blocks by mimicking a real browser
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    String? tokenToUse = authToken ?? _accessToken;

    if (requireAuth && tokenToUse != null && tokenToUse.isNotEmpty) {
      String cleanToken = tokenToUse.replaceFirst('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';

      print('--- API DEBUG ---');
      print('URL: $_baseUrl');
      print('Auth: Sending Bearer Token (Starts with: ${cleanToken.length > 10 ? cleanToken.substring(0, 10) : cleanToken}...)');
    }

    return headers;
  }

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParameters, bool requireAuth = false, String? authToken}) async {
    final String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    Uri uri = Uri.parse('$_baseUrl$path');

    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    try {
      print('GET Request to: $uri');
      final response = await http.get(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
      );

      _logResponse(response);
      handleResponseError(response);
      return response;
    } catch (e) {
      print('ApiClient GET Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> post(String endpoint, dynamic body, {bool requireAuth = false, String? authToken}) async {
    final String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$_baseUrl$path');

    try {
      print('POST Request to: $uri');
      final response = await http.post(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
        body: jsonEncode(body),
      );
      _logResponse(response);
      handleResponseError(response);
      return response;
    } catch (e) {
      print('ApiClient POST Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static void _logResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response Body Snippet: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
    }
  }

  static void handleResponseError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 403) {
      throw Exception('Client error (403): Access Forbidden. Please check User-Agent or Token permissions.');
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized (401): Please log in again.');
    }

    throw Exception('Request Failed with Status: ${response.statusCode}');
  }
}