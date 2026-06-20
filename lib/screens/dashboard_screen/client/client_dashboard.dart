import 'package:flutter/material.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/appointments_page.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'lawyer_find.dart';
import 'calendar.dart';
import 'package:insaafconnect/screens/chat/message.dart';
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
    const MessageScreen(),
    const AppointmentsPage(role: AppointmentRole.client)
  ];

  @override
  Widget build(BuildContext context) {
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
                    "Client",
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
                setState(() => currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.brown),
              title: const Text("Lawyer Find"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.brown),
              title: const Text("My Calendar"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.brown),
              title: const Text("Messages"),
              onTap: () {
                Get.back();
                setState(() => currentIndex = 3);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Colors.brown,
              ), // ← fix icon
              title: const Text("Appointments"),
              onTap: () {
                Get.to(() => const AppointmentsPage(role: AppointmentRole.client));
                setState(() => currentIndex = 4); // ← this now works
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

      // ───────── BODY ─────────
      body: IndexedStack(index: currentIndex, children: pages),

      // ───────── BOTTOM NAVIGATION ─────────
      bottomNavigationBar: currentIndex >= 4
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                selectedItemColor: Colors.brown,
                unselectedItemColor: Colors.brown,
                backgroundColor: const Color(0xFFF5EFE6),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header ──
          const Text(
            'Welcome Back, Ali!',
            style: TextStyle(
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
          _CaseCard(
            title: 'Property Dispute',
            lawyer: 'Adv. Ahmed Khan',
            date: '2026-01-05',
            status: 'In Progress',
            statusColor: const Color(0xFFB5651D),
            statusBg: const Color(0xFFF5E6D3),
          ),
          const SizedBox(height: 12),
          _CaseCard(
            title: 'Contract Review',
            lawyer: 'Adv. Sarah Ali',
            date: '2025-12-20',
            status: 'Completed',
            statusColor: const Color(0xFF2E7D32),
            statusBg: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 12),
          _CaseCard(
            title: 'Legal Consultation',
            lawyer: 'Adv. Bilal Ahmed',
            date: '2026-01-12',
            status: 'Scheduled',
            statusColor: const Color(0xFF6B6B6B),
            statusBg: const Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 28),

          // ── Upcoming Appointments ──
          const Text(
            'Upcoming Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AppointmentCard(
                  title: 'Court Hearing',
                  lawyer: 'Adv. Ahmed Khan',
                  dateTime: '2026-01-10 at 10:00 AM',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AppointmentCard(
                  title: 'Consultation',
                  lawyer: 'Adv. Sarah Ali',
                  dateTime: '2026-01-15 at 2:00 PM',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
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
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
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
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.brown,
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
