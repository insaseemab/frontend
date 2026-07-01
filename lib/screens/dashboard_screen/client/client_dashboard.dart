import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/screens/appointments/appointments_page.dart';
import 'package:insaafconnect/screens/chat/conversation.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:insaafconnect/screens/dashboard_screen/profile.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
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

  final List<Widget> pages = [
    const HomeScreen(),
    const LawyerFindScreen(),
    const CalendarScreen(),
    const ConversationsScreen(),
    const AppointmentsPage(role: AppointmentRole.client),
    const ManageCasesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

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
          color: AppColors.beige,
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
    IconButton(
      icon: const CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.darkBrown,
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
                      color: AppColors.white,
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
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Client",
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.darkBrown),
              title: const Text("Home"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppColors.darkBrown),
              title: const Text("Lawyer Find"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 1);
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
                setState(() => currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.darkBrown),
              title: const Text("Messages"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 3);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.darkBrown,
              ), // ← fix icon
              title: const Text("Appointments"),
              onTap: () {
                Get.to(
                  () => const AppointmentsPage(role: AppointmentRole.client),
                );
                setState(() => currentIndex = 4); // ← this now works
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.darkBrown,
              ), // ← fix icon
              title: const Text("Cases"),
              onTap: () {
                Get.to(() => const ManageCasesPage());
                setState(() => currentIndex = 5); // ← this now works
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

      // ───────── BODY ─────────
      body: IndexedStack(index: currentIndex, children: pages),

      // ───────── BOTTOM NAVIGATION ─────────
      bottomNavigationBar: currentIndex >= 4
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFEADDD0), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
                selectedItemColor: AppColors.darkBrown,
                unselectedItemColor: AppColors.darkBrown,
                backgroundColor: AppColors.beige,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Lawyer Find',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'My Calendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                ],
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

  final box = GetStorage();
  late final String userName;

  @override
  void initState() {
    super.initState();
    userName = box.read('userName') ?? "User";
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String token = box.read('token') ?? '';
      final result = await CasesService.fetchMyCases(token);

      setState(() {
        cases = result;
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
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Header ──
            Text(
              "Welcome Back, $userName!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C23),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's what's happening with your legal matters",
              style: TextStyle(fontSize: 14, color: Color(0xFF8C7B6B)),
            ),
            const SizedBox(height: 28),

            // ── Recent Cases ──
            const Text(
              'Recent Cases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C23),
              ),
            ),
            const SizedBox(height: 14),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.darkBrown),
                ),
              )
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF5C6CB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Couldn't load your cases.",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loadData,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            else if (cases.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.beige,
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
                children: List.generate(cases.length > 3 ? 3 : cases.length, (
                  index,
                ) {
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

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  SHARED WIDGETS
// ════════════════════════════════════════════════

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
            color: AppColors.darkBrown.withOpacity(0.05),
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
              color: AppColors.darkBrown,
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