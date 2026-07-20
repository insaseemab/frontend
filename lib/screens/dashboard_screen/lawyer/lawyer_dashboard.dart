import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/client/calendar.dart';
import 'package:insaafconnect/screens/appointments/appointments_page.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/screens/chat/message.dart';
import 'package:insaafconnect/screens/dashboard_screen/profile.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/screens/notifications.dart';

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
        backgroundColor: AppColors.beige,
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
                color: AppColors.darkBrown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
  // 🔔 Notification bell
  Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        icon: const Icon(Icons.notifications, color: Color(0xFF6B4F3F)),
        onPressed: () => Get.to(() => const NotificationsScreen()),
      ),
      Positioned(
        right: 8,
        top: 8,
        child: Container(
          height: 9,
          width: 9,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  ),

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
              decoration: const BoxDecoration(color: AppColors.darkBrown),
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
              leading: const Icon(Icons.home, color: AppColors.darkBrown),
              title: const Text("Home"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: AppColors.darkBrown),
              title: const Text("Active Cases"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.darkBrown),
              title: const Text("Appointments"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.darkBrown),
              title: const Text("Messages"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 3);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: AppColors.darkBrown,
              ),
              title: const Text("My Calendar"),
              onTap: () {
                Get.back();
                Get.toNamed('/calendar');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.darkBrown),
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
        selectedItemColor: AppColors.darkBrown,
        unselectedItemColor: AppColors.darkBrown,
        backgroundColor: AppColors.beige,
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
        AppointmentService.getMyAppointments(),
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
    final activeCases = cases.where((c) => c['case_status']?.toString().toLowerCase() != 'completed' && c['case_status']?.toString().toLowerCase() != 'closed').toList();

    // Calculate Lawyer Earnings
    double totalEarnings = 0;
    double thisMonthEarnings = 0;
    final now = DateTime.now();
    for (final a in appointments) {
      if (a['payment_status'] == 1) {
        final double amt = double.tryParse(a['payment_amount']?.toString() ?? '') ?? 0.0;
        totalEarnings += amt;
        final startRaw = a['slot_start_time'];
        if (startRaw != null) {
          final start = DateTime.tryParse(startRaw.toString());
          if (start != null && start.year == now.year && start.month == now.month) {
            thisMonthEarnings += amt;
          }
        }
      }
    }

    return RefreshIndicator(
      color: AppColors.darkBrown,
      onRefresh: loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkBrown,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, Adv. ${widget.userName}",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Manage your legal practice and matters easily",
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stat cards (Cases & Active Cases) ─────────────
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Total Cases",
                      '${cases.length}',
                      Icons.folder,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "Active Cases",
                      '${activeCases.length}',
                      Icons.folder_open,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Stat cards (Appointments) ────────────────────
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Appointments",
                      '${appointments.length}',
                      Icons.event,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "Today's Appointments",
                      '${todaysAppointments.length}',
                      Icons.today,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Earnings cards ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _earningsCard(
                    'PKR ${totalEarnings.toStringAsFixed(0)}',
                    'Total Professional Earnings',
                    Icons.attach_money,
                    AppColors.earningsOrange,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _earningsCard(
                    'PKR ${thisMonthEarnings.toStringAsFixed(0)}',
                    '${_monthName(DateTime.now().month)} ${DateTime.now().year} Earnings',
                    Icons.calendar_today_outlined,
                    AppColors.earningsGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Today's Schedule ──────────────────────────────
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            if (todaysAppointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No appointments scheduled for today.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: todaysAppointments.map(
                  (a) => _scheduleCard(
                    _formatTime(a['slot_start_time']?.toString()),
                    (a['case_type'] ??
                            a['short_description'] ??
                            'Appointment')
                        .toString(),
                    (a['client_name'] ?? 'Client #${a['client_id']}')
                        .toString(),
                    _formatDuration(
                      a['slot_start_time']?.toString(),
                      a['slot_end_time']?.toString(),
                    ),
                  ),
                ).toList(),
              ),
            const SizedBox(height: 24),

            // ── Active Cases ──────────────────────────────────
            const Text(
              "Active Cases",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            if (activeCases.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No active cases.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: activeCases.take(3).map(
                  (c) => _caseCard(
                    (c['name'] ?? c['title'] ?? 'Untitled Case').toString(),
                    (c['client_name'] ?? 'Client #${c['client_id']}').toString(),
                    (c['hearing_date'] ?? '—').toString(),
                    (c['case_status'] ?? '—').toString(),
                    _statusColor(c['case_status']?.toString()),
                  ),
                ).toList(),
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

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withOpacity(0.10),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.darkBrown),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.labelSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _earningsCard(String val, String lbl, IconData ic, Color bg) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(ic, size: 16, color: AppColors.white),
                ),
                Icon(
                  Icons.north_east,
                  size: 14,
                  color: AppColors.white.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              val,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              lbl,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      );
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

                    title: Text("${c['client_name']}"),

                    subtitle: Text("Conversation ID ${c['id']}"),

                    onTap: () {
                      Get.to(
                        () => const MessageScreen(),
                        arguments: {
                          "conversation_id": c["id"],

                          "receiver_id": c["client_id"],

                          "other_name": "${c['client_name']}",
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