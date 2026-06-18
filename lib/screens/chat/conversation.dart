import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessageService _service = MessageService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  bool isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    fetchConversations();
    _searchController.addListener(_onSearchChanged);

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchConversations(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredConversations = conversations.where((conv) {
        final name = (conv["other_name"] as String? ?? "").toLowerCase();
        final msg = (conv["last_message"] as String? ?? "").toLowerCase();
        return name.contains(query) || msg.contains(query);
      }).toList();
    });
  }

  Future<void> fetchConversations({bool silent = false}) async {
    final data = await _service.fetchConversations();

    if (mounted) {
      setState(() {
        conversations = List<Map<String, dynamic>>.from(data);
        filteredConversations = conversations;
        isLoading = false;
      });
    }
  }

  String _formatTime(dynamic isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString.toString()).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text("Messages"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: Colors.white10, height: 1),
        ),
        backgroundColor: const Color(0xFF3D2B1F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── SEARCH BAR ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.black38),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── SUBTITLE ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chat with lawyers and clients",
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ),
          ),

          // ── LIST ────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredConversations.isEmpty
                    ? const Center(child: Text("No conversations yet"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conv = filteredConversations[index];
                          final unread = conv["unread_count"] as int? ?? 0;
                          final name =
                              conv["other_name"] as String? ?? "User";

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                "/message",
                                arguments: {
                                  "conversation_id": conv["id"],
                                  "receiver_id": conv["lawyer_id"],
                                  "other_name":
                                      conv["lawyer_name"] ??
                                      conv["other_name"] ??
                                      "Lawyer",
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF3D2B1F),
                                    child: Text(
                                      name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Name + last message
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3D2B1F),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          conv["last_message"] ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Time + unread badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatTime(conv["last_at"]),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      if (unread > 0) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3D2B1F),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}