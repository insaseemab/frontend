import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'dart:typed_data'; 

class AuthService {
  static const String baseUrl = "http://localhost:3000";
  static final box = GetStorage();

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Server error',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data['message']};
      } else {
        return {"success": false, "message": data['error'] ?? "Something went wrong"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data['message']};
      } else {
        return {"success": false, "message": data['error'] ?? "Something went wrong"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

static Future<Map<String, dynamic>> register(
  Map<String, dynamic> body, {
  Uint8List? licenseImageBytes,
  String? licenseImageName,
}) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));

    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (licenseImageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'license',
          licenseImageBytes,
          filename: licenseImageName ?? 'license.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'userId': data['userId']};
    } else {
      return {
        'success': false,
        'message': data['error'] ?? data['message'] ?? 'Register failed',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Server error'};
  }
}
  }
