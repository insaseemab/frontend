import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MessageService {
  final String baseUrl = "http://localhost:3000";

  String get _token => GetStorage().read("token") ?? "";

 
  Map<String, String> get _headers => {
    "Authorization": "Bearer $_token",
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

 
  Future<Map<String, dynamic>?> startConversation({required int lawyerId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations"),
      headers: _headers,
      body: jsonEncode({"lawyer_id": lawyerId}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

 
  Future<List<Map<String, dynamic>>> fetchMyConversations() async {
    final response = await http.get(
      Uri.parse("$baseUrl/conversations/mine"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  
  Future<List<Map<String, dynamic>>> fetchMessages({
    required int conversationId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/messages/conversation/$conversationId"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      
      final int myId = GetStorage().read("userId") ?? 0;

      return data.map((m) {
        final map = Map<String, dynamic>.from(m);
        map["is_mine"] = map["sender_id"] == myId;
        map["body"] = map["message"];
        return map;
      }).toList();
    }
    return [];
  }

  
  Future<Map<String, dynamic>?> sendMessage({
    required int conversationId,
    required int receiverId,
    required String body,
  }) async {
    final int myId = GetStorage().read("userId") ?? 0;

    final response = await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: _headers,
      body: jsonEncode({
        "conversation_id": conversationId,
        "receiver_id": receiverId,
        "message": body,
      }),
    );

    if (response.statusCode == 201) {
      return {
        "is_mine": true,
        "body": body,
        "message": body,
        "sender_id": myId,
        "created_at": DateTime.now().toIso8601String(),
      };
    }
    return null;
  }

  
  Future<void> markAsRead({required int conversationId}) async {
    await http.patch(
      Uri.parse("$baseUrl/messages/read/$conversationId"),
      headers: _headers,
    );
  }
}