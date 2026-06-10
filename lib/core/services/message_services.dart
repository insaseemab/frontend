import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MessageService {
  final String baseUrl = "http://127.0.0.1:3000";

  String get _token => GetStorage().read("token") ?? "";

  // your backend reads raw token, not "Bearer token"
  Map<String, String> get _headers => {
    "Authorization": _token,
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // =============================================
  // POST /conversations  body: { lawyer_id }
  // =============================================
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

  // =============================================
  // GET /conversations
  // =============================================
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final response = await http.get(
      Uri.parse("$baseUrl/conversations"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // =============================================
  // GET /messages/conversation/:conversationId
  // =============================================
  Future<List<Map<String, dynamic>>> fetchMessages({
    required int conversationId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/messages/conversation/$conversationId"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final int myId = GetStorage().read("user_id") ?? 0;

      return data.map((m) {
        final map = Map<String, dynamic>.from(m);
        map["is_mine"] = map["sender_id"] == myId;
        map["body"] = map["message"];  // DB column is "message"
        return map;
      }).toList();
    }
    return [];
  }

  // =============================================
  // POST /messages
  // body: { conversation_id, receiver_id, message }
  // =============================================
  Future<Map<String, dynamic>?> sendMessage({
    required int conversationId,
    required int receiverId,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: _headers,
      body: jsonEncode({
        "conversation_id": conversationId,
        "receiver_id": receiverId,
        "message": body,   // DB column is "message" not "body"
      }),
    );
    if (response.statusCode == 201) {
      // backend returns { message: "Message sent", id: result.insertId }
      // build the message map manually for instant UI update
      return {
        "is_mine": true,
        "body": body,
        "message": body,
        "sender_id": GetStorage().read("user_id") ?? 0,
        "created_at": DateTime.now().toIso8601String(),
      };
    }
    return null;
  }

  // =============================================
  // PATCH /messages/read/:conversationId
  // =============================================
  Future<void> markAsRead({required int conversationId}) async {
    await http.patch(
      Uri.parse("$baseUrl/messages/read/$conversationId"),
      headers: _headers,
    );
  }
}