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
  final token = GetStorage().read('token');
  final response = await http.get(
    Uri.parse('${Environment.apiBaseUrl}/notifications/mine'), // was /notifications
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load notifications');
  }
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