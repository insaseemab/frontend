import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/message_services.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int get conversationId =>
      (Get.arguments as Map?)?["conversation_id"] as int? ?? 0;
  String get otherName =>
      (Get.arguments as Map?)?["other_name"] as String? ?? "Chat";
  int get receiverId => (Get.arguments as Map?)?["receiver_id"] as int? ?? 0;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  Timer? _pollTimer;

  int get myUserId => GetStorage().read("user_id") ?? 0;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _messageService.markAsRead(conversationId: conversationId);

    // Poll every 5 seconds for new messages
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMessages({bool silent = false}) async {
    final data = await _messageService.fetchMessages(
      conversationId: conversationId,
    );

    if (mounted) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
        if (!silent) isLoading = false;
        isLoading = false;
      });

      if (data.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> sendMessage() async {
    final body = _inputController.text.trim();
    if (body.isEmpty || isSending) return;

    setState(() => isSending = true);
    _inputController.clear();

    final sent = await _messageService.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      body: body,
    );

    if (sent != null && mounted) {
      setState(() {
        messages.add(sent);
        isSending = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D2B1F),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Text(
              "Online",
              style: TextStyle(fontSize: 11, color: Color(0xFFB8D4B0)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── MESSAGES LIST ──────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(
                    child: Text("Say hello! Start the conversation."),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      // ← Use is_mine from service, NOT sender_id comparison
                      final isMine = msg["is_mine"] == true;

                      return _MessageBubble(
                        body: msg["body"] ?? "",
                        isMine: isMine,
                        senderName: msg["sender_name"] ?? "",
                        createdAt: msg["created_at"] ?? "",
                      );
                    },
                  ),
          ),

          // ── INPUT BAR ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D2B1F),
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── MESSAGE BUBBLE ─────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final String body;
  final bool isMine;
  final String senderName;
  final String createdAt;

  const _MessageBubble({
    required this.body,
    required this.isMine,
    required this.senderName,
    required this.createdAt,
  });

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF3D2B1F) : const Color(0xFFEDE8DF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Show sender name on received messages (like RiceMart)
            if (!isMine && senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2B1F),
                  ),
                ),
              ),

            // Message body
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // Timestamp
            Text(
              _formatTime(createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white.withOpacity(0.65) : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
