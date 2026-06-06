import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/appoint.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/managelawyers.dart';

// ════════════════════════════════════════════════════════════════
// AdminDashboardScreen
// ════════════════════════════════════════════════════════════════
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final box = GetStorage();
  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homePage(),
      const Managelawyers(),
      const ManageCasesPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown,
        backgroundColor: const Color(0xFFF5EFE6),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user), label: "Manage lawyers"),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: "Manage Cases"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HOME PAGE
  // ══════════════════════════════════════════════════════════════
  Widget _homePage() {
    return Scaffold(
      backgroundColor: Colors.white,
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
                borderRadius: BorderRadius.circular(10)),
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
                fontSize: 20),
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
                      borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/logo.png',
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Insaaf Connect",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Text("Admin Panel",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.brown),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              setState(() => currentIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.brown),
            title: const Text("Manage Lawyers"),
            onTap: () {
              Navigator.pop(context);
              setState(() => currentIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: Colors.brown),
            title: const Text("Manage Cases"),
            onTap: () {
              Navigator.pop(context);
              setState(() => currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.brown),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              setState(() => currentIndex = 3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.brown),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              // Add your logout logic here
            },
          ),
        ],
      ),
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back, Admin",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Manage your platform easily",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Platform stat cards ────────────────────────────
            SizedBox(
              height: 100,
              child: Row(children: [
                Expanded(child: _statCard("Cases", "120", Icons.folder)),
                const SizedBox(width: 12),
                Expanded(child: _statCard("Clients", "80", Icons.people)),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(children: [
                Expanded(child: _statCard("Lawyers", "45", Icons.gavel)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _statCard("Pending lawyers", "11", Icons.pending)),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Earnings cards ─────────────────────────────────
            Row(children: [
              Expanded(
                  child: _earningsCard('PKR 43,000', 'Total Platform Earnings',
                      Icons.attach_money, const Color(0xFFC48A6A))),
              const SizedBox(width: 14),
              Expanded(
                  child: _earningsCard('PKR 8,500', 'May 2026 Earnings',
                      Icons.calendar_today_outlined, const Color(0xFF6B7D6B))),
            ]),
            const SizedBox(height: 14),

            // ── Payment count cards ────────────────────────────
            Row(children: [
              Expanded(
                  child: _countCard(
                      Icons.account_balance_wallet_outlined,
                      'Manual Payments',
                      4)),
              const SizedBox(width: 14),
              Expanded(
                  child: _countCard(
                      Icons.credit_card_outlined, 'Card Payments', 4)),
            ]),
            const SizedBox(height: 18),

            
          ],
        ),
      ),
    );
  }

  // ── Stat card (Cases / Clients / Lawyers) ──────────────────
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.brown),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Earnings card ───────────────────────────────────────────
  Widget _earningsCard(String val, String lbl, IconData ic, Color bg) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(ic, size: 16, color: Colors.white),
            ),
            Icon(Icons.north_east,
                size: 14, color: Colors.white.withOpacity(0.5)),
          ]),
          const SizedBox(height: 14),
          Text(val,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text(lbl,
              style:
                  TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
        ]),
      );

  // ── Payment count card ──────────────────────────────────────
  Widget _countCard(IconData ic, String lbl, int n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: const Color(0xFFF5EFE8),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(ic, size: 18, color: Colors.brown),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$n',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            Text(lbl,
                style: const TextStyle(
                    fontSize: 11.5, color: Colors.brown)),
          ]),
        ]),
      );
}
 