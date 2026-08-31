import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/screens/appointments/appointments_page.dart';
import 'package:insaafconnect/screens/chat/conversation.dart';
import 'package:insaafconnect/screens/dashboard_screen/profile.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/notifications.dart';
import 'lawyer_find.dart';
import 'calendar.dart';
import 'package:get/get.dart';
// ════════════════════════════════════════════════
//  CLIENT DASHBOARD SCREEN  (Bottom Nav Shell)
// ════════════════════════════════════════════════

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int currentIndex = 0;

  // Only 4 items appear in the bottom bar. Appointments (pageIndex 3) is
  // deliberately excluded here and reached only via the drawer.
  final List<_NavItem> _navItems = const [
    _NavItem(0, Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(1, Icons.search, Icons.search, 'Lawyers'),
    _NavItem(2, Icons.calendar_month_outlined, Icons.calendar_month, 'Calendar'),
    _NavItem(3, Icons.message_outlined, Icons.message, 'Chat'),
  ];

  final List<Widget> pages = [
    const HomeScreen(),                                     // 0
    const LawyerFindScreen(),                                // 1
    const CalendarScreen(isNested: true),                    // 2
    const ConversationsScreen(),                              // 3
    const AppointmentsPage(role: AppointmentRole.client),    // 4 (drawer-only)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
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
                color: AppColors.Brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.Brown),
            onPressed: () => Get.to(() => const NotificationsScreen()),
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.Brown,
              child: Icon(Icons.person, color: AppColors.white, size: 18),
            ),
            onPressed: () => Get.to(() => const ProfileScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.beige,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.Brown),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Insaaf Connect",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Client",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.Brown),
              title: const Text(
                "Home",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppColors.Brown),
              title: const Text(
                "Find Lawyer",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.Brown),
              title: const Text(
                "My Calendar",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.Brown),
              title: const Text(
                "Appointments",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.Brown),
              title: const Text(
                "Messages",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.Brown),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: AppColors.Brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                final box = GetStorage();
                box.erase();
                Get.offAll(() => LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: _navItems.map((item) {
                final bool isSelected = currentIndex == item.pageIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => currentIndex = item.pageIndex),
                    child: Container(
                      color: AppColors.beige,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: AppColors.Brown,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.Brown,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  HOME SCREEN  (Tab 1 — Dashboard content)
// ════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> cases = [];
  List<dynamic> appointments = [];

  final box = GetStorage();
  late final String userName;

  @override
  void initState() {
    super.initState();
    final user = Map<String, dynamic>.from(box.read('user') ?? {});
    userName = (user['name'] ?? box.read('userName') ?? "User").toString();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String token = box.read('token') ?? '';
      final results = await Future.wait([
        CasesService.fetchMyCases(token),
        AppointmentService.getMyAppointments(),
      ]);

      setState(() {
        cases = results[0];
        appointments = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _caseTitle(Map c) =>
      (c['name'] ?? c['case_type'] ?? 'Untitled Case').toString();

  String _lawyerName(Map c) =>
      (c['lawyer_name'] ??
              c['lawyer'] ??
              c['lawyer_id']?.toString() ??
              'Lawyer')
          .toString();

  String _caseDate(Map c) =>
      (c['hearing_date'] ?? c['case_start_date'] ?? '').toString();

  String _caseStatus(Map c) => (c['case_status'] ?? 'Pending').toString();

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return AppColors.success;
      case 'in progress':
      case 'in_progress':
        return const Color(0xFFB5651D);
      case 'rejected':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF6B6B6B);
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'in progress':
      case 'in_progress':
        return const Color(0xFFF5E6D3);
      case 'rejected':
        return const Color(0xFFFDECEA);
      default:
        return const Color(0xFFEEEEEE);
    }
  }

  String _formatStatusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.Brown));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Couldn't load dashboard: $errorMessage", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final activeCases = cases.where((c) => c['case_status']?.toString().toLowerCase() != 'completed' && c['case_status']?.toString().toLowerCase() != 'closed').toList();

    // Upcoming appointments count
    final now = DateTime.now();
    final upcomingAppointments = appointments.where((a) {
      final startRaw = a['slot_start_time'];
      if (startRaw == null) return false;
      final start = DateTime.tryParse(startRaw.toString());
      if (start == null) return false;
      return start.isAfter(now);
    }).toList();

    // Calculate Client Spent
    double totalSpent = 0;
    double thisMonthSpent = 0;
    for (final a in appointments) {
      if (a['payment_status'] == 1) {
        final double amt = double.tryParse(a['payment_amount']?.toString() ?? '') ?? 0.0;
        totalSpent += amt;
        final startRaw = a['slot_start_time'];
        if (startRaw != null) {
          final start = DateTime.tryParse(startRaw.toString());
          if (start != null && start.year == now.year && start.month == now.month) {
            thisMonthSpent += amt;
          }
        }
      }
    }

    return RefreshIndicator(
      color: AppColors.Brown,
      onRefresh: _loadData,
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
                color: AppColors.Brown,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $userName",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Track your active cases and legal appointments",
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
                      "Upcoming",
                      '${upcomingAppointments.length}',
                      Icons.upcoming,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Spent cards ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _earningsCard(
                    'PKR ${totalSpent.toStringAsFixed(0)}',
                    'Total Consultation Fees',
                    Icons.payments_outlined,
                    AppColors.earningsOrange,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _earningsCard(
                    'PKR ${thisMonthSpent.toStringAsFixed(0)}',
                    '${_monthName(DateTime.now().month)} ${DateTime.now().year} Fees',
                    Icons.calendar_today_outlined,
                    AppColors.earningsGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Recent Cases',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.Brown,
              ),
            ),
            const SizedBox(height: 12),
            if (cases.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEADDD0)),
                ),
                child: const Text(
                  "You don't have any cases yet.",
                  style: TextStyle(color: Color(0xFF8C7B6B)),
                ),
              )
            else
              Column(
                children: List.generate(cases.length > 3 ? 3 : cases.length, (index) {
                  final c = Map<String, dynamic>.from(cases[index]);
                  final status = _caseStatus(c);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CaseCard(
                      title: _caseTitle(c),
                      lawyer: _lawyerName(c),
                      date: _caseDate(c),
                      status: _formatStatusLabel(status),
                      statusColor: _statusColor(status),
                      statusBg: _statusBg(status),
                    ),
                  );
                }),
              ),
          ],
        ),
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

class _CaseCard extends StatelessWidget {
  final String title;
  final String lawyer;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _CaseCard({
    required this.title,
    required this.lawyer,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.Brown.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF3E2C23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lawyer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAA9988),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String title;
  final String lawyer;
  final String dateTime;

  const _AppointmentCard({
    required this.title,
    required this.lawyer,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.Brown,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF3E2C23),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  lawyer,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAA9988),
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

class _NavItem {
  final int pageIndex; // real index into `pages`
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.pageIndex, this.icon, this.activeIcon, this.label);
}