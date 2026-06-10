import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/message_services.dart';
class LawyerConversationScreen extends StatefulWidget {
  const LawyerConversationScreen({super.key});

  @override
  State<LawyerConversationScreen> createState() =>
      _LawyerConversationScreenState();
}

class _LawyerConversationScreenState
    extends State<LawyerConversationScreen> {

  final MessageService service = MessageService();

  List conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data =
    await service.fetchLawyerConversations();

    setState(() {
      conversations = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),

      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF3D2B1F),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {

                final item = conversations[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3D2B1F),
                    child: Text(
                      item["client_name"] != null
                          ? item["client_name"][0]
                          : "C",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  title: Text(
                    item["client_name"] ?? "Client",
                  ),

                  subtitle: Text(
                    item["last_message"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  onTap: () {
                    Get.toNamed(
                      "/message",
                      arguments: {
                        "conversation_id": item["id"],
                        "receiver_id": item["client_id"],
                        "other_name":
                            item["client_name"] ?? "Client",
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}