import 'dart:convert';
import 'package:http/http.dart' as http;


class CasesService {
  static const String baseUrl = "http://insaaf.sandbox.pk";

  static Future<List<dynamic>> fetchCases() async {
    print('fetch cases');
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        print(response.statusCode);

        final data = jsonDecode(response.body);
        print(data);

        return data;
      } else {
        throw Exception("Failed to load cases");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
  // CREATE new case
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
  required String paymentStatus,
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
      "payment_status": paymentStatus,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create case: ${response.body}');
  }
}
static Future updateCase({
  required int id,
  required String descriptionCase,
  required String phone,
  required String address,
  required String caseType,
  required String name,
  required String caseStartDate,
  required String caseStatus,
  required String departConcern,
  required String hearingDate,
  required String paymentStatus,
  required String token,
})
 async {
  final response = await http.put(
    Uri.parse('$baseUrl/cases/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "description_case": descriptionCase,
      "phone": phone,
      "address": address,
      "case_type": caseType,
      "name": name,
      "case_start_date": caseStartDate,
      "case_status": caseStatus,
      "depart_concern": departConcern,
      "hearing_date": hearingDate,
      "payment_status": paymentStatus,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
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
