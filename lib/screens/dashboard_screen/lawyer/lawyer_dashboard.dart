import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/appoint.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/screens/chat/message.dart';
import 'package:insaafconnect/screens/chat/conversation.dart';


class LawyerDashboard extends StatefulWidget {
  const LawyerDashboard({super.key});

  @override
  State<LawyerDashboard> createState() => _LawyerDashboardState();
}

class _LawyerDashboardState extends State<LawyerDashboard> {
  final box = GetStorage();
  int _currentIndex = 0;

  late final String userName;

  @override
  void initState() {
    super.initState();
    userName = box.read('userName') ?? "Ahmed Khan";
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomePage(userName: userName),
      const ManageCasesPage(),
      const AdminAppointmentsPage(),
      const _MessagesPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ── TOP APPBAR (matches Figma) ──────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE6DED3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.balance,
                size: 18,
                color: Color(0xFF6B4F3F),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Insaaf Connect",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.person_outline,
              color: Color(0xFF6B4F3F),
              size: 18,
            ),
            label: const Text(
              "Profile",
              style: TextStyle(color: Color(0xFF6B4F3F)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── PAGE BODY ───────────────────────────────────────
      body: pages[_currentIndex],

      // ── BOTTOM NAVIGATION (matches Figma) ───────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown,
        backgroundColor: const Color(0xFFF5EFE6),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: "Active Cases",
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Appointments",
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Messages",
            backgroundColor: Colors.brown,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 1. HOME PAGE
// ══════════════════════════════════════════════════════════
class _HomePage extends StatelessWidget {
  final String userName;
  const _HomePage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            "Welcome, Adv. $userName",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "You have 3 appointments scheduled for today",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // ── Active Cases + Today's Schedule side by side ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT — Active Cases
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Active Cases",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _caseCard(
                      "Property Dispute",
                      "Ali Raza",
                      "2026-01-10",
                      "High",
                      Colors.red,
                    ),
                    _caseCard(
                      "Contract Review",
                      "Fatima Khan",
                      "2026-01-15",
                      "Medium",
                      Colors.orange,
                    ),
                    _caseCard(
                      "Legal Consultation",
                      "Hassan Ahmed",
                      "2026-01-20",
                      "Low",
                      Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // RIGHT — Today's Schedule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _scheduleCard(
                      "10:00 AM",
                      "Court Hearing",
                      "Ali Raza",
                      "2 hours",
                    ),
                    _scheduleCard(
                      "2:00 PM",
                      "Client Meeting",
                      "Fatima Khan",
                      "1 hour",
                    ),
                    _scheduleCard(
                      "4:00 PM",
                      "Document Review",
                      "Hassan Ahmed",
                      "1 hour",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _caseCard(
    String title,
    String client,
    String date,
    String priority,
    Color priorityColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Client: $client",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            "Next Hearing: $date",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(
    String time,
    String title,
    String client,
    String duration,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6DED3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time,
              size: 18,
              color: Color(0xFF6B4F3F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  client,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 2. ACTIVE CASES PAGE
// ══════════════════════════════════════════════════════════
class _ActiveCasesPage extends StatelessWidget {
  const _ActiveCasesPage();

  @override
  Widget build(BuildContext context) {
    final cases = [
      {
        "title": "Property Dispute",
        "client": "Ali Raza",
        "date": "2026-01-10",
        "priority": "High",
        "color": Colors.red,
      },
      {
        "title": "Contract Review",
        "client": "Fatima Khan",
        "date": "2026-01-15",
        "priority": "Medium",
        "color": Colors.orange,
      },
      {
        "title": "Legal Consultation",
        "client": "Hassan Ahmed",
        "date": "2026-01-20",
        "priority": "Low",
        "color": Colors.green,
      },
      {
        "title": "Family Law Case",
        "client": "Sara Malik",
        "date": "2026-01-25",
        "priority": "High",
        "color": Colors.red,
      },
      {
        "title": "Corporate Dispute",
        "client": "Tariq Khan",
        "date": "2026-02-01",
        "priority": "Medium",
        "color": Colors.orange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active Cases",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${cases.length} cases in progress",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cases.length,
              itemBuilder: (context, i) {
                final c = cases[i];
                final color = c['color'] as Color;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Client: ${c['client']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Next Hearing: ${c['date']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c['priority'] as String,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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

// ══════════════════════════════════════════════════════════
// 3. APPOINTMENTS PAGE
// ══════════════════════════════════════════════════════════
class _AppointmentsPage extends StatelessWidget {
  const _AppointmentsPage();

  @override
  Widget build(BuildContext context) {
    final today = [
      {
        "time": "10:00 AM",
        "title": "Court Hearing",
        "client": "Ali Raza",
        "duration": "2 hours",
      },
      {
        "time": "2:00 PM",
        "title": "Client Meeting",
        "client": "Fatima Khan",
        "duration": "1 hour",
      },
      {
        "time": "4:00 PM",
        "title": "Document Review",
        "client": "Hassan Ahmed",
        "duration": "1 hour",
      },
    ];
    final tomorrow = [
      {
        "time": "11:00 AM",
        "title": "Legal Consultation",
        "client": "Sara Malik",
        "duration": "45 min",
      },
      {
        "time": "3:00 PM",
        "title": "Case Briefing",
        "client": "Tariq Khan",
        "duration": "1 hour",
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Appointments",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Upcoming scheduled appointments",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _sectionLabel("Today"),
          const SizedBox(height: 10),
          ...today.map((a) => _appointmentCard(a)),

          const SizedBox(height: 16),
          _sectionLabel("Tomorrow"),
          const SizedBox(height: 10),
          ...tomorrow.map((a) => _appointmentCard(a)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF6B4F3F),
      ),
    );
  }

  Widget _appointmentCard(Map<String, String> a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6DED3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF6B4F3F),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  a['client']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                a['time']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                a['duration']!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 4. MESSAGES PAGE
// ══════════════════════════════════════════════════════════
class _MessagesPage extends StatefulWidget {
  const _MessagesPage();

  @override
  State<_MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<_MessagesPage> {

  final MessageService service = MessageService();

  List conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {

    final data = await service.fetchConversations();

    if (mounted) {
      setState(() {
        conversations = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (conversations.isEmpty) {
      return const Center(
        child: Text("No conversations found"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Messages",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "Your client conversations",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,

              itemBuilder: (context, index) {

                final c = conversations[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),

                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFF6B4F3F),

                      child: Text(
                        "C",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),

                    title: Text(
                      "Client #${c['client_id']}",
                    ),

                    subtitle: Text(
                      "Conversation ID ${c['id']}",
                    ),

                    onTap: () {

                      Get.to(
                        () => const MessageScreen(),
                        arguments: {

                          "conversation_id":
                              c["id"],

                          "receiver_id":
                              c["client_id"],

                          "other_name":
                              "Client #${c['client_id']}",
                        },
                      );
                    },
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