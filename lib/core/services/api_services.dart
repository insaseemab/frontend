import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = "http://insaaf.sandbox.pk";

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
    int? clientId,
  }) async {
    final date = slotStartTime.split(' ')[0];
    final body = jsonEncode({
      if (clientId != null) 'client_id': clientId,
      'lawyer_id': lawyerId,
      'date': date,
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
    final date = slotStartTime.split(' ')[0];
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'date': date,
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

  // ── Internal: throw a meaningful error on non-2xx, even if the
  // ── server responded with HTML instead of JSON (e.g. a 404/413/500
  // ── error page) — this is what was causing the FormatException crash.
  static void _checkStatus(http.Response res) {
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
    final date = slotStartTime.split(' ')[0];
    final body = jsonEncode({
      'lawyer_id': lawyerId,
      'date': date,
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

  /// GET /appointments/mine — role-based (client/lawyer/admin)
  static Future<List<dynamic>> getMyAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/mine'),
      headers: _authHeaders(), // token already handled here
    );
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// PATCH /appointments/:id/pay
  static Future<void> payAppointment(
    int appointmentId,
    String paymentMethod,
    Uint8List? screenshotBytes,
  ) async {
    String? receiptBase64;
    if (screenshotBytes != null) {
      receiptBase64 = base64Encode(screenshotBytes);
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
      String message = 'Payment failed';
      try {
        final decoded = jsonDecode(res.body);
        message = decoded['error'] ?? message;
      } catch (_) {
        // Server returned non-JSON (most likely an HTML error page —
        // commonly a 413 Payload Too Large if the screenshot is large,
        // since it's base64-encoded inline in the JSON body).
        if (res.statusCode == 413) {
          message =
              'Screenshot is too large to upload. Please choose a smaller image.';
        } else {
          message = 'Server error (${res.statusCode}). Please try again.';
        }
      }
      throw ApiException(statusCode: res.statusCode, message: message);
    }
  }

  static Future<void> approvePayment({required int id}) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$id/approve-payment'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
  }

  /// POST /appointments/:id/convert-to-case
  static Future<int> convertToCase({required int id}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/appointments/$id/convert-to-case'),
      headers: _authHeaders(),
    );
    _checkStatus(res);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['caseId'] as int;
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
      headers: _authHeaders(),
      body: jsonEncode({
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
        'location': data['location'],
      }),
    );
    _checkStatus(basicRes);

    // 2. Update lawyer specific profile if fields exist
    if (data.containsKey('specialization') || data.containsKey('experience')) {
      final lawyerRes = await http.put(
        Uri.parse('$baseUrl/update-profile'),
        headers: _authHeaders(),
        body: jsonEncode({
          'specialization': data['specialization'],
          'experience': data['experience'],
          'location': data['location'],
        }),
      );
      _checkStatus(lawyerRes);
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
      headers: _authHeaders(),
      body: body,
    );
    _checkStatus(res);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}