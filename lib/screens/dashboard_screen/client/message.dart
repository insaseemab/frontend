import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String? openedChat;
  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Adv. Ahmed Khan',
      'initials': 'AK',
      'lastMessage': 'The hearing is scheduled for Monday.',
      'time': '10:30 AM',
      'unread': 2,
      'case': 'Property Dispute',
      'messages': [
        {'text': 'Hello, how can I help you?', 'isMe': false, 'time': '9:00 AM'},
        {'text': 'I need an update on my property case.', 'isMe': true, 'time': '9:05 AM'},
        {'text': 'Sure, I reviewed all documents.', 'isMe': false, 'time': '9:10 AM'},
        {'text': 'The hearing is scheduled for Monday.', 'isMe': false, 'time': '10:30 AM'},
      ],
    },
    {
      'name': 'Adv. Sarah Ali',
      'initials': 'SA',
      'lastMessage': 'Please send the signed contract.',
      'time': 'Yesterday',
      'unread': 0,
      'case': 'Contract Review',
      'messages': [
        {'text': 'I have reviewed the contract thoroughly.', 'isMe': false, 'time': 'Yesterday 2:00 PM'},
        {'text': 'Are there any issues?', 'isMe': true, 'time': 'Yesterday 2:05 PM'},
        {'text': 'Minor clause on page 4 needs revision.', 'isMe': false, 'time': 'Yesterday 2:10 PM'},
        {'text': 'Please send the signed contract.', 'isMe': false, 'time': 'Yesterday 3:00 PM'},
      ],
    },
    {
      'name': 'Adv. Bilal Ahmed',
      'initials': 'BA',
      'lastMessage': 'Your consultation is confirmed.',
      'time': 'Jan 12',
      'unread': 1,
      'case': 'Legal Consultation',
      'messages': [
        {'text': 'I have booked a consultation for you.', 'isMe': false, 'time': 'Jan 12 11:00 AM'},
        {'text': 'Thank you!', 'isMe': true, 'time': 'Jan 12 11:05 AM'},
        {'text': 'Your consultation is confirmed.', 'isMe': false, 'time': 'Jan 12 11:10 AM'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (openedChat != null) {
      final chat = chats.firstWhere((c) => c['name'] == openedChat);
      return _ChatView(
        chat: chat,
        controller: _msgController,
        onBack: () => setState(() => openedChat = null),
        onSend: (text) {
          setState(() {
            (chat['messages'] as List).add({
              'text': text,
              'isMe': true,
              'time': 'Now',
            });
            _msgController.clear();
          });
        },
      );
    }

    return Column(
      children: [
        // ── Search ──
        Container(
          color: const Color(0xFFF1ECE5),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search messages...',
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFFAA9988)),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.brown),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFEADDD0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFEADDD0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.brown, width: 1.5),
              ),
            ),
          ),
        ),

        // ── Chat List ──
        Expanded(
          child: ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(
              color: Color(0xFFEADDD0),
              height: 1,
              indent: 76,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFF5EDE4),
                  child: Text(
                    chat['initials'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                      fontSize: 15,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF3E2C23),
                        ),
                      ),
                    ),
                    Text(
                      chat['time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAA9988),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      chat['case'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat['lastMessage'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8C7B6B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((chat['unread'] as int) > 0)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.brown,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat['unread']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                onTap: () => setState(() => openedChat = chat['name']),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChatView extends StatefulWidget {
  final Map<String, dynamic> chat;
  final TextEditingController controller;
  final VoidCallback onBack;
  final Function(String) onSend;

  const _ChatView({
    required this.chat,
    required this.controller,
    required this.onBack,
    required this.onSend,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = widget.chat['messages'] as List;

    return Column(
      children: [
        // ── Chat AppBar ──
        Container(
          color: const Color(0xFFF1ECE5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.brown, size: 20),
                onPressed: widget.onBack,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF5EDE4),
                child: Text(
                  widget.chat['initials'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF3E2C23),
                      ),
                    ),
                    Text(
                      widget.chat['case'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.brown),
            ],
          ),
        ),

        // ── Messages ──
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final msg = messages[i];
              final isMe = msg['isMe'] as bool;
              return Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.brown
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        border: isMe
                            ? null
                            : Border.all(
                                color: const Color(0xFFEADDD0)),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe
                              ? Colors.white
                              : const Color(0xFF3E2C23),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        msg['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAA9988),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Input ──
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF1ECE5),
            border:
                Border(top: BorderSide(color: Color(0xFFEADDD0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: Color(0xFFAA9988)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFEADDD0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFEADDD0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: Colors.brown, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (widget.controller.text.trim().isNotEmpty) {
                    widget.onSend(widget.controller.text.trim());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}