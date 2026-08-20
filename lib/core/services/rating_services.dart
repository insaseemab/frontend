import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'api_services.dart';

class RatingService {
  static final box = GetStorage();
  
  static Future<void> submitRating(int appointmentId, int lawyerId, int rating, String review) async {
    final token = box.read('token');
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/ratings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'appointment_id': appointmentId,
        'lawyer_id': lawyerId,
        'rating': rating,
        'review': review,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to submit rating: ${response.body}');
    }
  }
}