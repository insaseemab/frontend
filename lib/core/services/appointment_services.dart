import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_services.dart';

class AppointmentService {
  static const String baseUrl = ApiService.baseUrl;
  static Future<List<dynamic>> getAllAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }


  static Future<Map<String, dynamic>> getAppointmentById(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }


  static Future<List<dynamic>> getAppointmentsByStatus(String status) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/filter?status=$status'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }


  static Future<List<dynamic>> getAppointmentsByClient(int clientId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/client/$clientId'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

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
      headers: ApiService.authHeaders(),
      body: body,
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

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
      headers: ApiService.authHeaders(),
      body: body,
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }


  static Future<void> deleteAppointment(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
  }

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
      headers: ApiService.authHeaders(),
      body: body,
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
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
      headers: ApiService.authHeaders(),
      body: body,
    );
    ApiService.checkStatus(res);
  }

  static Future<List<dynamic>> getMyAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments/mine'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

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
      headers: ApiService.authHeaders(),
      body: body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Payment failed';
      try {
        final decoded = jsonDecode(res.body);
        message = decoded['error'] ?? message;
      } catch (_) {
        
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
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
  }
/// POST /appointments/:id/stripe-intent — create a Stripe PaymentIntent
  static Future<String> createStripePaymentIntent(
    int appointmentId,
    dynamic amount,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/appointments/$appointmentId/stripe-intent'),
      headers: ApiService.authHeaders(),
      body: jsonEncode({'amount': amount}),
    );
    ApiService.checkStatus(res);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['clientSecret'] as String;
  }

  /// PATCH /appointments/:id/confirm-payment — confirm a completed Stripe payment
  static Future<void> confirmAppointmentPayment(
    int appointmentId,
    String paymentIntentId,
  ) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/confirm-payment'),
      headers: ApiService.authHeaders(),
      body: jsonEncode({'payment_intent_id': paymentIntentId}),
    );
    ApiService.checkStatus(res);
  }
  
  static Future<int> convertToCase({required int id}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/appointments/$id/convert-to-case'),
      headers: ApiService.authHeaders(),
    );
    ApiService.checkStatus(res);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['caseId'] as int;
  }
}