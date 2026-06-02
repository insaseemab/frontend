import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

// ════════════════════════════════════════════════
//  API SERVICE  — centralised HTTP + auth token
// ════════════════════════════════════════════════

class ApiService {
  // ── Change this to your actual server URL ──
  static const String baseUrl ="http://localhost:3000"; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator

  static final _box = GetStorage();

  // ── Token helpers ──
  static String? getToken() => _box.read<String>('auth_token');

  static void saveToken(String token) => _box.write('auth_token', token);

  static void removeToken() => _box.remove('auth_token');

  static Map<String, String> _authHeaders() {
    final token = getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ════════════════════════════════════════════════
  //  APPOINTMENT ENDPOINTS
  // ════════════════════════════════════════════════

  /// GET /appointments
  static Future<List<dynamic>> getAllAppointments() async {
    final headers = _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// GET /appointments/:id
  static Future<Map<String, dynamic>> getAppointmentById(int id) async {
    final headers = _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET /appointments/filter?status=pending|accepted|rejected
  static Future<List<dynamic>> getAppointmentsByStatus(String status) async {
    final headers = _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/filter?status=$status'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// GET /appointments/client/:clientId
  static Future<List<dynamic>> getAppointmentsByClient(int clientId) async {
    final headers = _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/client/$clientId'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// POST /appointments
  static Future<Map<String, dynamic>> createAppointment({
    required int lawyerId,
    required String lawType,
    required String caseType,
    required String shortDescription,
    required String slotStartTime,
    required String slotEndTime,
    required String appointmentMode,
    required String paymentMode,
    double? paymentAmount,
    String? paymentReceipt,
  }) async {
    final headers = _authHeaders();
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'law_type': lawType,
      'case_type': caseType,
      'short_description': shortDescription,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'appointment_mode': appointmentMode,
      'payment_mode': paymentMode,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentReceipt != null) 'payment_receipt': paymentReceipt,
    });

    final res = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: headers,
      body: body,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PUT /appointments/:id
  static Future<Map<String, dynamic>> updateAppointment({
    required int id,
    required int lawyerId,
    required String lawType,
    required String caseType,
    required String shortDescription,
    required String slotStartTime,
    required String slotEndTime,
    required String appointmentMode,
    required String paymentMode,
    double? paymentAmount,
    String? paymentReceipt,
  }) async {
    final headers = _authHeaders();
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'law_type': lawType,
      'case_type': caseType,
      'short_description': shortDescription,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'appointment_mode': appointmentMode,
      'payment_mode': paymentMode,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentReceipt != null) 'payment_receipt': paymentReceipt,
    });

    final res = await http.put(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: headers,
      body: body,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// DELETE /appointments/:id
  static Future<void> deleteAppointment(int id) async {
    final headers = _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: headers,
    );
    _checkStatus(res);
  }

  /// PATCH /appointments/:id/status/:status
  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required int id,
    required String status, // pending | accepted | rejected
    double? paymentAmount,
  }) async {
    final headers = _authHeaders();
    final body = jsonEncode({
      if (paymentAmount != null) 'payment_amount': paymentAmount,
    });

    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$id/status/$status'),
      headers: headers,
      body: body,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Internal: throw on non-2xx ──
  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(res.body);
      throw ApiException(
        statusCode: res.statusCode,
        message: body['error'] ?? 'Unknown error',
      );
    }
  }
}

// ════════════════════════════════════════════════
//  CUSTOM EXCEPTION
// ════════════════════════════════════════════════

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}