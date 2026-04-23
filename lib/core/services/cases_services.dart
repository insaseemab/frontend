import 'dart:convert';
import 'package:http/http.dart' as http;

class CasesService {
  static const String baseUrl = "http://localhost:3000/lawyers";

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
}