import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
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
import 'package:insaafconnect/screens/dashboard_screen/edit_profile.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/services/settings_services.dart';

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
      backgroundColor: AppColors.beige,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Insaaf Connect",
              style: TextStyle(
                color: AppColors.Brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // 🔔 Notification bell
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF6B4F3F)),
            onPressed: () => Get.to(() => const NotificationsScreen()),
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
              decoration: const BoxDecoration(color: AppColors.Brown),
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
              leading: const Icon(Icons.home, color: AppColors.Brown),
              title: const Text("Home"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: AppColors.Brown),
              title: const Text("Active Cases"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.Brown,
              ),
              title: const Text("Appointments"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.Brown),
              title: const Text("Messages"),
              onTap: () {
                Get.back();
                setState(() => _currentIndex = 3);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: AppColors.Brown,
              ),
              title: const Text("My Calendar"),
              onTap: () {
                Get.back();
                Get.toNamed('/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.Brown),
              title: const Text("Edit Profile"),
              onTap: () {
                Get.back();
                Get.to(() => const EditLawyerProfile());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.Brown),
              title: const Text("Logout"),
              onTap: () {
                GetStorage().erase();
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
        selectedItemColor: AppColors.Brown,
        unselectedItemColor: AppColors.Brown,
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
  Map<String, dynamic>? lawyerData;
  Map<String, dynamic>? settingsData;
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
      final userId = box.read<int>('id') ?? -1;
      final results = await Future.wait([
        CasesService.fetchMyCases(token),
        AppointmentService.getMyAppointments(),
        LawyerService().fetchLawyerById(userId),
        SettingsService.getSettings(),
      ]);

      if (!mounted) return;
      setState(() {
        cases = results[0] as List<dynamic>;
        appointments = results[1] as List<dynamic>;
        lawyerData = results[2] as Map<String, dynamic>?;
        settingsData = results[3] as Map<String, dynamic>?;
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
    final activeCases = cases
        .where(
          (c) =>
              c['case_status']?.toString().toLowerCase() != 'completed' &&
              c['case_status']?.toString().toLowerCase() != 'closed',
        )
        .toList();

    // Calculate Lawyer Earnings
    double totalEarnings = 0;
    double thisMonthEarnings = 0;
    final now = DateTime.now();
    for (final a in appointments) {
      if (a['payment_status'] == 1) {
        final double amt =
            double.tryParse(a['payment_amount']?.toString() ?? '') ?? 0.0;
        totalEarnings += amt;
        final startRaw = a['slot_start_time'];
        if (startRaw != null) {
          final start = DateTime.tryParse(startRaw.toString());
          if (start != null &&
              start.year == now.year &&
              start.month == now.month) {
            thisMonthEarnings += amt;
          }
        }
      }
    }

    return RefreshIndicator(
      color: AppColors.Brown,
      onRefresh: loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Subscription banner ─────────────────────────────
            Builder(
              builder: (context) {
                final subDateStr = lawyerData?['subscription_expiry'];
                DateTime? subDate;
                if (subDateStr != null) {
                  subDate = DateTime.tryParse(subDateStr.toString());
                }
                final isExpired = subDate == null || subDate.isBefore(DateTime.now());
                final fee = settingsData?['subscription_fee'] ?? '2000';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpired ? Colors.red.shade400 : Colors.green.shade400,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isExpired ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpired ? 'Subscription Expired' : 'Subscription Active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isExpired ? Colors.red.shade900 : Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isExpired
                                  ? 'Your subscription has expired. Please pay PKR $fee to the Admin via JazzCash to renew your account.'
                                  : 'Your subscription is valid until ${subDateStr.toString().split('T')[0]}.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isExpired ? Colors.red.shade900 : Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Welcome banner ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.Brown,
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
                color: AppColors.Brown,
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
                children: todaysAppointments
                    .map(
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
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),

            // ── Active Cases ──────────────────────────────────
            const Text(
              "Active Cases",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.Brown,
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
                children: activeCases
                    .take(3)
                    .map(
                      (c) => _caseCard(
                        (c['name'] ?? c['title'] ?? 'Untitled Case').toString(),
                        (c['client_name'] ?? 'Client #${c['client_id']}')
                            .toString(),
                        (c['hearing_date'] ?? '—').toString(),
                        (c['case_status'] ?? '—').toString(),
                        _statusColor(c['case_status']?.toString()),
                      ),
                    )
                    .toList(),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.Brown.withOpacity(0.10),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.Brown),
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

// ⚠️ Add this import at the TOP of lawyer_dashboard.dart:
// import 'dart:async';

class _MessagesPage extends StatefulWidget {
  const _MessagesPage();

  @override
  State<_MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<_MessagesPage> {
  final MessageService service = MessageService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  bool loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    loadConversations();
    _searchController.addListener(_onSearchChanged);

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadConversations(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _clientName(Map<String, dynamic> c) {
    return (c['client_name'] ?? 'Client').toString();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredConversations = conversations.where((c) {
        final name = _clientName(c).toLowerCase();
        final msg = (c["last_message"] as String? ?? "").toLowerCase();
        return name.contains(query) || msg.contains(query);
      }).toList();
    });
  }

  Future<void> loadConversations({bool silent = false}) async {
    final data = await service.fetchMyConversations();

    if (mounted) {
      setState(() {
        conversations = List<Map<String, dynamic>>.from(data);
        filteredConversations = _searchController.text.isEmpty
            ? conversations
            : filteredConversations;
        if (_searchController.text.isEmpty) filteredConversations = conversations;
        loading = false;
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
    return Container(
      color: AppColors.beige,
      child: Column(
        children: [
          // ── HEADER ──
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Messages",
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: TextStyle(
                    color: AppColors.Brown.withOpacity(0.6), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.Brown),
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

          // ── SUBTITLE ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your client conversations",
                style: TextStyle(
                    fontSize: 12, color: AppColors.Brown.withOpacity(0.7)),
              ),
            ),
          ),

          // ── LIST ──
          Expanded(
            child: loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.Brown))
                : filteredConversations.isEmpty
                    ? const Center(child: Text("No conversations yet"))
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final c = filteredConversations[index];
                          final unread = c["unread_count"] as int? ?? 0;
                          final name = _clientName(c);
                          final avatarLetter = name.isNotEmpty
                              ? name.trim().substring(0, 1).toUpperCase()
                              : "C";

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => const MessageScreen(),
                                arguments: {
                                  "conversation_id": c["id"],
                                  "receiver_id": c["client_id"],
                                  "other_name": name,
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
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
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.brown,
                                    child: Text(
                                      avatarLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.Brown,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          c["last_message"] ??
                                              "Conversation ID ${c['id']}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.Brown
                                                  .withOpacity(0.75)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatTime(c["last_at"]),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.Brown
                                                .withOpacity(0.6)),
                                      ),
                                      if (unread > 0) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.Brown,
                                            borderRadius: BorderRadius.circular(12),
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