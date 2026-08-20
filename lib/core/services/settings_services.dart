import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_services.dart';

class SettingsService {
  static Future<Map<String, dynamic>> getSettings() async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/settings'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<void> updateSetting(String key, String value) async {
    final res = await http.put(
      Uri.parse('${ApiService.baseUrl}/settings'),
      headers: ApiService.authHeaders(),
      body: jsonEncode({
        'setting_key': key,
        'setting_value': value,
      }),
    );
    ApiService.checkStatus(res);
  }
}