import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  static final _box = GetStorage();

  static String? getToken() => _box.read<String>('token');
  static void saveToken(String token) => _box.write('token', token);
  static void removeToken() => _box.remove('token');

  /// Shared auth headers — used by ApiService and other services
  /// (e.g. AppointmentService) that need authenticated requests.
  static Map<String, String> authHeaders() {
    final token = getToken();
    print('Token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Shared: throw a meaningful error on non-2xx, even if the
  // ── server responded with HTML instead of JSON (e.g. a 404/413/500
  // ── error page).
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

  // ════════════════════════════════════════════════
  //  PROFILE / USER ENDPOINTS
  // ════════════════════════════════════════════════

  /// PUT /edit-profile & /update-profile — update profile
  static Future<Map<String, dynamic>> updateProfile({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    // 1. Update basic profile for all roles
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

    // 2. Update lawyer specific profile if fields exist
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

  /// PUT /change-password — change password
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