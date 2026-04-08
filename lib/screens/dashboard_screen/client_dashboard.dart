import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'approve_lawyer.dart';
import 'admin_dashboard.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const InsaafConnectApp());
}

class InsaafConnectApp extends StatelessWidget {
  const InsaafConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insaaf Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC18668),
          background: const Color(0xFFF7F4EF),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class CaseItem {
  final String title;
  final String advocate;
  final String date;
  final CaseStatus status;

  const CaseItem({
    required this.title,
    required this.advocate,
    required this.date,
    required this.status,
  });
}

enum CaseStatus { inProgress, completed, scheduled }

class AppointmentItem {
  final String title;
  final String advocate;
  final String dateTime;

  const AppointmentItem({
    required this.title,
    required this.advocate,
    required this.dateTime,
  });
}

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<CaseItem> _cases = [
    CaseItem(
      title: 'Property Dispute',
      advocate: 'Adv. Ahmed Khan',
      date: '2026-01-05',
      status: CaseStatus.inProgress,
    ),
    CaseItem(
      title: 'Contract Review',
      advocate: 'Adv. Sarah Ali',
      date: '2025-12-20',
      status: CaseStatus.completed,
    ),
    CaseItem(
      title: 'Legal Consultation',
      advocate: 'Adv. Bilal Ahmed',
      date: '2026-01-12',
      status: CaseStatus.scheduled,
    ),
  ];

  static const List<AppointmentItem> _appointments = [
    AppointmentItem(
      title: 'Court Hearing',
      advocate: 'Adv. Ahmed Khan',
      dateTime: '2026-01-10 at 10:00 AM',
    ),
    AppointmentItem(
      title: 'Consultation',
      advocate: 'Adv. Sarah Ali',
      dateTime: '2026-01-15 at 2:00 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 28),
            _buildSectionTitle('Recent Cases'),
            const SizedBox(height: 12),
            _buildCasesList(),
            const SizedBox(height: 28),
            _buildSectionTitle('Upcoming Appointments'),
            const SizedBox(height: 12),
            _buildAppointmentsGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.white,
      leadingWidth: 160,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBE3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.balance_rounded,
                size: 18,
                color: Color(0xFFC18668),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Insaaf Connect',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2A),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF5F5E5A),
            size: 22,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF5F5E5A),
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5F5E5A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 0.5,
          color: const Color(0xFFE5E1D8),
        ),
      ),
    );
  }

  // ─── Welcome Header ─────────────────────────────────────────────────────────

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome Back, Ali!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Here's what's happening with your legal matters",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF888780),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── Section Title ───────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C2C2A),
        letterSpacing: -0.3,
      ),
    );
  }

  // ─── Cases List ─────────────────────────────────────────────────────────────

  Widget _buildCasesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE9E2), width: 0.5),
      ),
      child: Column(
        children: List.generate(_cases.length, (i) {
          final isLast = i == _cases.length - 1;
          return Column(
            children: [
              _CaseCard(item: _cases[i]),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: const Color(0xFFECE9E2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ─── Appointments Grid ───────────────────────────────────────────────────────

  Widget _buildAppointmentsGrid() {
    return Row(
      children: _appointments.map((appt) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: appt == _appointments.first ? 8 : 0,
            ),
            child: _AppointmentCard(item: appt),
          ),
        );
      }).toList(),
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.search_rounded, 'label': 'Lawyer Find'},
      {'icon': Icons.calendar_month_rounded, 'label': 'My Calendar'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Messages'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E1D8), width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = _selectedIndex == i;
              final icon = items[i]['icon'] as IconData;
              final label = items[i]['label'] as String;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFFC18668)
                            : const Color(0xFF888780),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFFC18668)
                              : const Color(0xFF888780),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Case Card Widget ─────────────────────────────────────────────────────────

class _CaseCard extends StatelessWidget {
  final CaseItem item;

  const _CaseCard({required this.item});

  Color get _statusBg {
    switch (item.status) {
      case CaseStatus.inProgress:
        return const Color(0xFFF5C4B3);
      case CaseStatus.completed:
        return const Color(0xFFC0DD97);
      case CaseStatus.scheduled:
        return const Color(0xFFD3D1C7);
    }
  }

  Color get _statusText {
    switch (item.status) {
      case CaseStatus.inProgress:
        return const Color(0xFF993C1D);
      case CaseStatus.completed:
        return const Color(0xFF3B6D11);
      case CaseStatus.scheduled:
        return const Color(0xFF444441);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case CaseStatus.inProgress:
        return 'In Progress';
      case CaseStatus.completed:
        return 'Completed';
      case CaseStatus.scheduled:
        return 'Scheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.advocate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB4B2A9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _statusText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Appointment Card Widget ──────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentItem item;

  const _AppointmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE9E2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFFC18668),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.advocate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dateTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB4B2A9),
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