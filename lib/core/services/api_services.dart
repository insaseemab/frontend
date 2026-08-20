import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";
  static final _box = GetStorage();

  static String? getToken() => _box.read<String>('token');
  static void saveToken(String token) => _box.write('token', token);
  static void removeToken() => _box.remove('token');

  static Map<String, String> authHeaders() {
    final token = getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Unknown error';
      try {
        final body = jsonDecode(res.body);
        message = body['error'] ?? message;
      } catch (_) {
        if (res.statusCode == 413) {
          message = 'The data sent is too large. Please try a smaller file.';
        } else if (res.statusCode == 404) {
          message = 'Requested resource was not found.';
        } else {
          message = 'Server error (${res.statusCode}). Please try again.';
        }
      }
      throw ApiException(statusCode: res.statusCode, message: message);
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final basicRes = await http.put(
      Uri.parse('$baseUrl/edit-profile'),
      headers: authHeaders(),
      body: jsonEncode({
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
        'location': data['location'],
      }),
    );
    checkStatus(basicRes);

    if (data.containsKey('specialization') || data.containsKey('experience')) {
      final lawyerRes = await http.put(
        Uri.parse('$baseUrl/update-profile'),
        headers: authHeaders(),
        body: jsonEncode({
          'specialization': data['specialization'],
          'experience': data['experience'],
          'location': data['location'],
        }),
      );
      checkStatus(lawyerRes);
    }

    return data;
  }

  static Future<void> updateLawyerProfile(Map<String, dynamic> data) async {
    final id = _box.read('id');
    final res = await http.put(
      Uri.parse('$baseUrl/lawyers/$id'),
      headers: authHeaders(),
      body: jsonEncode(data),
    );
    checkStatus(res);
  }

  static Future<void> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
  }) async {
    final body = jsonEncode({
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': newPassword,
    });

    final res = await http.put(
      Uri.parse('$baseUrl/change-password'),
      headers: authHeaders(),
      body: body,
    );
    checkStatus(res);
  }

}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}