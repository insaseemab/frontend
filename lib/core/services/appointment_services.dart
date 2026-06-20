import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  static final _box = GetStorage();

  static String? getToken() => _box.read<String>('token');
  static void saveToken(String token) => _box.write('token', token);
  static void removeToken() => _box.remove('token');

  static Map<String, String> _authHeaders() {
    final token = getToken();
    print('Token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ════════════════════════════════════════════════
  //  APPOINTMENT ENDPOINTS
  // ════════════════════════════════════════════════

  /// GET /appointments  — all appointments (admin)
  static Future<List<dynamic>> getAllAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// GET /appointments/:id
  static Future<Map<String, dynamic>> getAppointmentById(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET /appointments/filter?status=pending|accepted|rejected
  static Future<List<dynamic>> getAppointmentsByStatus(String status) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/filter?status=$status'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// GET /appointments/client/:clientId
  static Future<List<dynamic>> getAppointmentsByClient(int clientId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/client/$clientId'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// POST /appointments  — requires auth
  static Future<Map<String, dynamic>> createAppointment({
    required int lawyerId,
    required String lawType,
    required String caseType,
    required String shortDescription,
    required String slotStartTime,
    required String slotEndTime,
    required String appointmentMode,
  }) async {
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'law_type': lawType,
      'case_type': caseType,
      'short_description': shortDescription,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'appointment_mode': appointmentMode,
    });

    final res = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _authHeaders(),
      body: body,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PUT /appointments/:id  — requires auth
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
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'law_type': lawType,
      'case_type': caseType,
      'short_description': shortDescription,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'appointment_mode': appointmentMode,
    });

    final res = await http.put(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: _authHeaders(),
      body: body,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// DELETE /appointments/:id  — requires auth
  static Future<void> deleteAppointment(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
  }

  /// PATCH /appointments/:id/status/:status  — requires auth
  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required int id,
    required String status, // pending | accepted | rejected
    double? paymentAmount,
  }) async {
    final body = jsonEncode({
      if (paymentAmount != null) 'payment_amount': paymentAmount,
    });

    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$id/status/$status'),
      headers: _authHeaders(),
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

  static Future<void> editAppointment({
    required int id,
    required int lawyerId,
    required String lawType,
    required String caseType,
    required String shortDescription,
    required String slotStartTime,
    required String slotEndTime,
    required String appointmentMode,
  }) async {
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'law_type': lawType,
      'case_type': caseType,
      'short_description': shortDescription,
      'slot_start_time': slotStartTime,
      'slot_end_time': slotEndTime,
      'appointment_mode': appointmentMode,
    });
    final res = await http.put(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: _authHeaders(),
      body: body,
    );
    _checkStatus(res);
  }

  // static Future<List> getAppointmentsForLawyer(
  //     int lawyerId) async {

  //   final res = await http.get(
  //     Uri.parse('$baseUrl/appointments'),
  //     headers: _authHeaders(),
  //   );

  //   _checkStatus(res);

  //   final all = jsonDecode(res.body) as List;

  //   return all.where(
  //     (a) => a['lawyer_id'] == lawyerId,
  //   ).toList();
  // }
  /// GET /appointments/mine — role-based (client/lawyer/admin)
  static Future<List<dynamic>> getMyAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/mine'),
      headers: _authHeaders(), // token already handled here
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  // REPLACE the entire payAppointment() function
  static Future<void> payAppointment(
    int appointmentId,
    String paymentMethod,
    Uint8List? screenshotBytes, // ← changed from File?
  ) async {
    String? receiptBase64;
    if (screenshotBytes != null) {
      receiptBase64 = base64Encode(
        screenshotBytes,
      ); // ← no need to readAsBytes()
    }

    final body = jsonEncode({
      'payment_mode': paymentMethod,
      if (receiptBase64 != null) 'payment_receipt': receiptBase64,
    });

    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/pay'),
      headers: _authHeaders(),
      body: body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final decoded = jsonDecode(res.body);
      throw ApiException(
        statusCode: res.statusCode,
        message: decoded['error'] ?? 'Payment failed',
      );
    }
  }

  static Future<void> approvePayment({required int id}) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$id/approve-payment'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
  }

  // ════════════════════════════════════════════════
//  ADD THIS METHOD to ApiService in appointment_services.dart
//  (matches: POST /appointments/:id/convert-to-case, no body)
// ════════════════════════════════════════════════

  static Future<int> convertToCase({required int id}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/appointments/$id/convert-to-case'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['caseId'] as int;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
