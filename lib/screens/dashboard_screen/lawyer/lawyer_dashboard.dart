import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/client/calendar.dart';
import 'package:insaafconnect/screens/appointments/appointments_page.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/screens/chat/message.dart';
import 'package:insaafconnect/screens/dashboard_screen/profile.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/core/services/cases_services.dart';

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
    final user = Map<String, dynamic>.from(box.read('user') ?? {});
    userName = (user['name'] ?? "User").toString();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomePage(userName: userName),
      const ManageCasesPage(),
      const AppointmentsPage(role: AppointmentRole.lawyer),
      const _MessagesPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // ───────── APP BAR ─────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Insaaf Connect",
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF6B4F3F),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onPressed: () => Get.to(() => const ProfileScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5EFE6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.brown),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Insaaf Connect",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Lawyer",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.brown),
              title: const Text("Home"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.brown),
              title: const Text("Active Cases"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.brown),
              title: const Text("Appointments"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.brown),
              title: const Text("Messages"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 3);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.brown,
              ), // ← fix icon
              title: const Text("Calendar"),
              onTap: () {
                Get.to(() => const CalendarScreen());
                setState(() => _currentIndex = 4); // ← this now works
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.brown),
              title: const Text("Logout"),
              onTap: () {
                Get.offAll(() => LoginScreen());
              },
            ),
          ],
        ),
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
class _HomePage extends StatefulWidget {
  final String userName;
  const _HomePage({required this.userName});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final box = GetStorage();

  List<dynamic> cases = [];
  List<dynamic> appointments = [];
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final token = box.read<String>('token') ?? '';
      final results = await Future.wait([
        CasesService.fetchMyCases(token),
        ApiService.getMyAppointments(),
      ]);

      if (!mounted) return;
      setState(() {
        cases = results[0];
        appointments = results[1];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = "Failed to load dashboard data";
        loading = false;
      });
    }
  }

  // Appointments scheduled for today, sorted by start time
  List<dynamic> get _todaysAppointments {
    final today = DateTime.now();
    return appointments.where((a) {
      final startRaw = a['slot_start_time']; // ⚠️ ADJUST key if different
      if (startRaw == null) return false;
      final start = DateTime.tryParse(startRaw.toString());
      if (start == null) return false;
      return start.year == today.year &&
          start.month == today.month &&
          start.day == today.day;
    }).toList()..sort((a, b) {
      final aStart =
          DateTime.tryParse(a['slot_start_time'].toString()) ?? DateTime(0);
      final bStart =
          DateTime.tryParse(b['slot_start_time'].toString()) ?? DateTime(0);
      return aStart.compareTo(bStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() => loading = true);
                loadDashboardData();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final todaysAppointments = _todaysAppointments;
    final activeCases = cases.take(3).toList(); // show top 3 on dashboard

    return RefreshIndicator(
      onRefresh: loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              "Welcome, Adv. ${widget.userName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "You have ${todaysAppointments.length} appointment${todaysAppointments.length == 1 ? '' : 's'} scheduled for today",
              style: const TextStyle(color: Colors.grey),
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
                      if (activeCases.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "No active cases",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...activeCases.map(
                          (c) => _caseCard(
                            (c['name'] ?? c['title'] ?? 'Untitled Case')
                                .toString(), // ⚠️ ADJUST
                            (c['client_name'] ?? 'Client #${c['client_id']}')
                                .toString(), // ⚠️ ADJUST
                            (c['hearing_date'] ?? '—').toString(), // ⚠️ ADJUST
                            (c['case_status'] ?? '—').toString(), // ⚠️ ADJUST
                            _statusColor(c['case_status']?.toString()),
                          ),
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
                      if (todaysAppointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "No appointments today",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...todaysAppointments.map(
                          (a) => _scheduleCard(
                            _formatTime(a['slot_start_time']?.toString()),
                            (a['case_type'] ??
                                    a['short_description'] ??
                                    'Appointment')
                                .toString(), // ⚠️ ADJUST
                            (a['client_name'] ?? 'Client #${a['client_id']}')
                                .toString(), // ⚠️ ADJUST
                            _formatDuration(
                              a['slot_start_time']?.toString(),
                              a['slot_end_time']?.toString(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  String _formatDuration(String? startIso, String? endIso) {
    if (startIso == null || endIso == null) return '—';
    final start = DateTime.tryParse(startIso);
    final end = DateTime.tryParse(endIso);
    if (start == null || end == null) return '—';
    final diff = end.difference(start);
    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    final hours = diff.inMinutes / 60;
    return hours == hours.roundToDouble()
        ? "${hours.toInt()} hour${hours == 1 ? '' : 's'}"
        : "${diff.inMinutes} min";
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'urgent':
      case 'high':
        return Colors.red;
      case 'pending':
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
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
    final data = await service.fetchMyConversations();

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
      return const Center(child: CircularProgressIndicator());
    }

    if (conversations.isEmpty) {
      return const Center(child: Text("No conversations found"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Messages",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      backgroundColor: const Color(0xFF6B4F3F),

                      child: Text(
                        "C",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text("Client #${c['client_id']}"),

                    subtitle: Text("Conversation ID ${c['id']}"),

                    onTap: () {
                      Get.to(
                        () => const MessageScreen(),
                        arguments: {
                          "conversation_id": c["id"],

                          "receiver_id": c["client_id"],

                          "other_name": "Client #${c['client_id']}",
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
