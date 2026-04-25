import 'dart:convert';
import 'package:http/http.dart' as http;

class LawyerService {
  static const String _baseUrl = 'http://localhost:3000';

  // ─────────────────────────────────────────
  // 1. GET ALL LAWYERS
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchLawyers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lawyers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load lawyers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 2. GET SINGLE LAWYER BY ID
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> fetchLawyerById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lawyers/$id'),
        headers: {'Content-Type': 'application/json'},
      
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Lawyer not found');
      } else {
        throw Exception('Failed to fetch lawyer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 3. CREATE LAWYER
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> createLawyer({
    required String name,
    required String specialization,
    required String location,
    required String experience,
    required String cases,
    String rating = '0.0',
    String status = 'active',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/lawyers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'specialization': specialization,
          'location': location,
          'experience': experience,
          'cases': cases,
          'rating': rating,
          'status': status,
        }),
      );

      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('Validation error: ${error['error']}');
      } else {
        throw Exception('Failed to create lawyer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 4. UPDATE LAWYER
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> updateLawyer({
    required int id,
    required String name,
    required String specialization,
    required String location,
    required String experience,
    required String cases,
    required String rating,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/lawyers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'specialization': specialization,
          'location': location,
          'experience': experience,
          'cases': cases,
          'rating': rating,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Lawyer not found');
      } else {
        throw Exception('Failed to update lawyer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 5. DELETE LAWYER
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> deleteLawyer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/lawyers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Lawyer not found');
      } else {
        throw Exception('Failed to delete lawyer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 6. SEARCH LAWYERS BY SPECIALIZATION
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> searchLawyersBySpecialization(
      String specialization) async {
    try {
      final allLawyers = await fetchLawyers();
      return allLawyers
          .where((lawyer) =>
              lawyer['specialization']
                  .toString()
                  .toLowerCase()
                  .contains(specialization.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 7. SEARCH LAWYERS BY LOCATION
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> searchLawyersByLocation(
      String location) async {
    try {
      final allLawyers = await fetchLawyers();
      return allLawyers
          .where((lawyer) => lawyer['location']
              .toString()
              .toLowerCase()
              .contains(location.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // ─────────────────────────────────────────
  // 8. GET LAWYERS SORTED BY RATING
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchLawyersSortedByRating() async {
    try {
      final allLawyers = await fetchLawyers();
      allLawyers.sort((a, b) {
        final ratingA = double.tryParse(a['rating'].toString()) ?? 0.0;
        final ratingB = double.tryParse(b['rating'].toString()) ?? 0.0;
        return ratingB.compareTo(ratingA); // descending
      });
      return allLawyers;
    } catch (e) {
      throw Exception('Sort error: $e');
    }
  }
  // ─────────────────────────────────────────
// 9. APPROVE LAWYER
// ─────────────────────────────────────────
Future<Map<String, dynamic>> approveLawyer(int id) async {
  try {
    final response = await http.patch(
      Uri.parse('$_baseUrl/lawyers/$id/1'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Lawyer not found');
    } else {
      throw Exception('Failed to approve lawyer: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

// ─────────────────────────────────────────
// 10. DISAPPROVE LAWYER
// ─────────────────────────────────────────
Future<Map<String, dynamic>> disapproveLawyer(int id) async {
  try {
    final response = await http.patch(
      Uri.parse('$_baseUrl/lawyers/$id/0'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Lawyer not found');
    } else {
      throw Exception('Failed to disapprove lawyer: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}
}