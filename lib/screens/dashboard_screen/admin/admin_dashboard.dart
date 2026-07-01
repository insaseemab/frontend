import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/screens/appointments/appointments_page.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/managelawyers.dart';
import 'package:insaafconnect/screens/dashboard_screen/profile.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ── Holds every computed dashboard number in one place ──
class _DashboardStats {
  final int casesCount;
  final int lawyersCount;
  final int pendingLawyersCount;
  final int clientsCount; // approximated from unique client_id in appointments
  final double totalEarnings;
  final double thisMonthEarnings;
  final int manualPaymentsCount;
  final int cardPaymentsCount;

  _DashboardStats({
    required this.casesCount,
    required this.lawyersCount,
    required this.pendingLawyersCount,
    required this.clientsCount,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.manualPaymentsCount,
    required this.cardPaymentsCount,
  });
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final box = GetStorage();
  int currentIndex = 0;
  late Future<_DashboardStats> _statsFuture;

  final List<String> _titles = [
    'Insaaf Connect',
    'Insaaf Connect',
    'Insaaf Connect',
    'Insaaf Connect',
  ];

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  void _reload() {
    setState(() => _statsFuture = _loadStats());
  }

  // ── Fetches cases, lawyers, and appointments in parallel and derives stats ──
  Future<_DashboardStats> _loadStats() async {
    final results = await Future.wait([
      CaseApiService.fetchAllCases(),
      LawyerService().fetchLawyers(),
      ApiService.getAllAppointments(),
    ]);

    final cases = results[0] as List<CaseModel>;
    final lawyers = results[1] as List<Map<String, dynamic>>;
    final appointments = results[2] as List<dynamic>;

    // ── Pending lawyers: status isn't cleanly 0 (rejected) or 1 (approved) ──
    // TODO: if your backend actually uses a distinct value (e.g. status == 2)
    // for pending, swap the condition below to match it exactly.
    int pendingLawyers = 0;
    for (final l in lawyers) {
      final raw = l['status'];
      final s = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
      if (s != 0 && s != 1) pendingLawyers++;
    }

    // ── Clients: unique client_id seen across all appointments ──
    // TODO: replace with a real /clients count endpoint once available.
    final clientIds = <String>{};
    double totalEarnings = 0;
    double thisMonthEarnings = 0;
    int manualCount = 0;
    int cardCount = 0;
    final now = DateTime.now();

    for (final raw in appointments) {
      final apt = raw as Map<String, dynamic>;

      if (apt['client_id'] != null) {
        clientIds.add(apt['client_id'].toString());
      }

      final paymentApproved =
          apt['payment_status'] == 1 || apt['payment_status'] == true;
      final amount =
          double.tryParse(apt['payment_amount']?.toString() ?? '') ?? 0;

      if (paymentApproved && amount > 0) {
        totalEarnings += amount;

        final slotDate = DateTime.tryParse(
          apt['slot_start_time']?.toString() ?? '',
        );
        if (slotDate != null &&
            slotDate.year == now.year &&
            slotDate.month == now.month) {
          thisMonthEarnings += amount;
        }

        final mode = (apt['payment_mode'] ?? '').toString().toLowerCase();
        if (mode.contains('card')) {
          cardCount++;
        } else if (mode.isNotEmpty) {
          manualCount++;
        }
      }
    }

    return _DashboardStats(
      casesCount: cases.length,
      lawyersCount: lawyers.length,
      pendingLawyersCount: pendingLawyers,
      clientsCount: clientIds.length,
      totalEarnings: totalEarnings,
      thisMonthEarnings: thisMonthEarnings,
      manualPaymentsCount: manualCount,
      cardPaymentsCount: cardCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homePage(),
      const Managelawyers(),
      const ManageCasesPage(),
      const AppointmentsPage(role: AppointmentRole.admin),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
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
            Text(
              _titles[currentIndex],
              style: const TextStyle(
                color: AppColors.darkBrown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          if (currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.darkBrown),
              onPressed: _reload,
            ),
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
      drawer: _buildDrawer(),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.darkBrown,
        unselectedItemColor: AppColors.darkBrown,
        backgroundColor: AppColors.beige,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: "Manage lawyers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Manage Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Appointments",
          ),
        ],
      ),
    );
  }

  // ── DRAWER ──────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
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
                  "Admin Panel",
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
            leading: const Icon(Icons.verified_user, color: AppColors.darkBrown),
            title: const Text("Manage Lawyers"),
            onTap: () {
              Get.back();
              setState(() => currentIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: AppColors.darkBrown),
            title: const Text("Manage Cases"),
            onTap: () {
              Get.back();
              setState(() => currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.darkBrown),
            title: const Text("Appointments"),
            onTap: () {
              Get.back();
              setState(() => currentIndex = 3);
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
    );
  }

  // ── HOME PAGE (body only, no Scaffold) ──────────────────────
  Widget _homePage() {
    return FutureBuilder<_DashboardStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: CircularProgressIndicator(color: AppColors.darkBrown),
            ),
          );
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.labelSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final stats = snap.data!;

        return RefreshIndicator(
          color: AppColors.darkBrown,
          onRefresh: () async => _reload(),
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
                        "Welcome back, ${box.read('user')?['name'] ?? 'Admin'}",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Manage your platform easily",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Platform stat cards ──────────────────────────
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "Cases",
                          '${stats.casesCount}',
                          Icons.folder,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          "Clients",
                          '${stats.clientsCount}',
                          Icons.people,
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
                          "Lawyers",
                          '${stats.lawyersCount}',
                          Icons.gavel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          "Pending lawyers",
                          '${stats.pendingLawyersCount}',
                          Icons.pending,
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
                        'PKR ${stats.totalEarnings.toStringAsFixed(0)}',
                        'Total Platform Earnings',
                        Icons.attach_money,
                        AppColors.earningsOrange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _earningsCard(
                        'PKR ${stats.thisMonthEarnings.toStringAsFixed(0)}',
                        '${_monthName(DateTime.now().month)} ${DateTime.now().year} Earnings',
                        Icons.calendar_today_outlined,
                        AppColors.earningsGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Payment count cards ──────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _countCard(
                        Icons.account_balance_wallet_outlined,
                        'Manual Payments',
                        stats.manualPaymentsCount,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _countCard(
                        Icons.credit_card_outlined,
                        'Card Payments',
                        stats.cardPaymentsCount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }

  // ── Stat card ────────────────────────────────────────────────
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.darkBrown.withOpacity(0.10), blurRadius: 6),
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

  // ── Earnings card ────────────────────────────────────────────
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

  // ── Payment count card ───────────────────────────────────────
  Widget _countCard(IconData ic, String lbl, int n) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.beige,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ic, size: 18, color: AppColors.darkBrown),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$n',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              lbl,
              style: const TextStyle(fontSize: 11.5, color: AppColors.darkBrown),
            ),
          ],
        ),
      ],
    ),
  );
}