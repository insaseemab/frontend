import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class CasesService {
  static const String baseUrl = "http://localhost:3000";

 static Future<List<dynamic>> fetchCases() async {
  try {
    final box = GetStorage();
    final String token = box.read('token');

    final response = await http.get(
      Uri.parse('$baseUrl/cases'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load cases: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}

  // ─────────────────────────────────────────
  // GET ALL LAWYERS (for dropdown)
  // ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchLawyers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cases/lawyers'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load lawyers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ─────────────────────────────────────────
  // GET ALL CLIENTS (for dropdown)
  // ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchClients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cases/clients'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ─────────────────────────────────────────
  // CREATE new case
  // ─────────────────────────────────────────
  static Future<void> createCase({
    required String descriptionCase,
    required String clientId,
    required String lawyerId,
    required String phone,
    required String address,
    required String caseType,
    required String name,
    required String caseStartDate,
    required String caseStatus,
    required String departConcern,
    required String hearingDate,
    required int paymentStatus, // ← int
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cases'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "description_case": descriptionCase,
        "client_id": clientId,
        "lawyer_id": lawyerId,
        "phone": phone,
        "address": address,
        "case_type": caseType,
        "name": name,
        "case_start_date": caseStartDate,
        "case_status": caseStatus,
        "depart_concern": departConcern,
        "hearing_date": hearingDate,
        "payment_status": paymentStatus, // ← sent as int
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create case: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // UPDATE case
  // ─────────────────────────────────────────
  static Future<void> updateCase({
  required int id,
  required String name,
  required String caseType,
  required String caseStatus,
  required String descriptionCase,
  required String phone,
  required String address,
  required String caseStartDate,
  required String departConcern,
  required String hearingDate,
  required int paymentStatus,   // ← changed from String to int
  required String token,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/cases/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "name": name,
      "case_type": caseType,
      "case_status": caseStatus,
      "description_case": descriptionCase,
      "phone": phone,
      "address": address,
      "case_start_date": caseStartDate,
      "depart_concern": departConcern,
      "hearing_date": hearingDate,
      "payment_status": paymentStatus,   // now sent as int
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update case: ${response.body}');
  }
}
  // ─────────────────────────────────────────
  // GET MY CASES
  // ─────────────────────────────────────────
  static Future<List<dynamic>> fetchMyCases(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cases/mine'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load my cases");
    }
  }
}