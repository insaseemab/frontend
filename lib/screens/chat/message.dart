import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

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

  int get myUserId {
    final val = GetStorage().read("userId");
    if (val == null) return 0;
    return val is int ? val : int.tryParse(val.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _messageService.markAsRead(conversationId: conversationId);

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
        messages.add({
          ...sent,
          "sender_id": myUserId,
        });
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
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.Brown,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
            const Text(
              "Online",
              style: TextStyle(fontSize: 11, color: AppColors.sageGreen),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.Brown))
                : messages.isEmpty
                    ? Center(
                        child: Text("Say hello! Start the conversation.", style: AppTextStyles.bodyMedium),
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
                          final isMine = msg["sender_id"].toString() == myUserId.toString();

                          return _MessageBubble(
                            body: msg["message"] ?? "",
                            isMine: isMine,
                            senderName: msg["sender_name"] ?? "",
                            createdAt: msg["created_at"] ?? "",
                          );
                        },
                      ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.Brown.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: AppTextStyles.hint,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.Brown,
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: AppColors.white, size: 20),
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
          color: isMine ? AppColors.Brown : AppColors.beige,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.Brown,
                  ),
                ),
              ),

            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? AppColors.white : AppColors.Brown,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _formatTime(createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? AppColors.white.withValues(alpha: 0.65)
                    : AppColors.Brown.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}