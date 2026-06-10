import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';

class LawyerConversationScreen extends StatefulWidget {
  const LawyerConversationScreen({super.key});

  @override
  State<LawyerConversationScreen> createState() =>
      _LawyerConversationScreenState();
}

class _LawyerConversationScreenState
    extends State<LawyerConversationScreen> {

  final MessageService _service = MessageService();

  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {

    final data =
        await _service.fetchLawyerConversations();

    if (!mounted) return;

    setState(() {
      conversations = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF3D2B1F),
        foregroundColor: Colors.white,
        title: const Text("Messages"),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : conversations.isEmpty
              ? const Center(
                  child: Text(
                    "No conversations found",
                  ),
                )
              : ListView.builder(
                  itemCount: conversations.length,

                  itemBuilder: (context, index) {

                    final c =
                        conversations[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(
                            0xFF3D2B1F,
                          ),

                          child: Text(
                            (c["client_name"] ??
                                    "C")[0]
                                .toUpperCase(),

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),

                        title: Text(
                          c["client_name"] ??
                              "Client",
                        ),

                        subtitle: Text(
                          c["last_message"] ??
                              "Open conversation",
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),

                        trailing:
                            c["unread_count"] !=
                                        null &&
                                    c["unread_count"] >
                                        0
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Colors.red,

                                    child: Text(
                                      c["unread_count"]
                                          .toString(),

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors
                                                .white,
                                        fontSize:
                                            11,
                                      ),
                                    ),
                                  )
                                : null,

                        onTap: () {

                          Get.toNamed(
                            "/message",
                            arguments: {

                              "conversation_id":
                                  c["id"],

                              "receiver_id":
                                  c["client_id"],

                              "other_name":
                                  c["client_name"] ??
                                      "Client",
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}