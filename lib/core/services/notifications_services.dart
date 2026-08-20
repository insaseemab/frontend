// core/services/notifications_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/config/environment.dart';

class NotificationService {
 static const String baseUrl = Environment.apiBaseUrl;

  final _box = GetStorage();

  String get _token => _box.read('token') ?? '';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> getNotifications() async {
  final box = GetStorage();
  
  final res = await http.get(
    Uri.parse('$baseUrl/notifications/mine'),
    headers: _headers,
  );


  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }
  throw Exception('Failed to load notifications (${res.statusCode})');
}
  Future<void> markAsRead(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to mark as read (${res.statusCode})');
    }
  }

  Future<void> markAllRead() async {
    final res = await http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to mark all as read (${res.statusCode})');
    }
  }
}