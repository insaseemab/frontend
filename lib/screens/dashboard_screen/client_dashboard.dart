import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  final box = GetStorage();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userName = box.read('userName') ?? "User";

    final List<Widget> pages = [
      _homePage(userName),
      _casesPage(),
      _messagesPage(),
      _profilePage(userName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFF5EFE6),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Cases"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ── HOME PAGE ──────────────────────────────────────────
  Widget _homePage(String userName) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Insaaf Connect",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(children: [
                    Icon(Icons.notifications_none),
                    SizedBox(width: 12),
                    Icon(Icons.person_outline),
                  ]),
                ],
              ),

              const SizedBox(height: 20),

              Text("Welcome Back, $userName!",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text(
                "Here's what's happening with your legal matters",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Find a Lawyer Card
              const Text("Quick Actions",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4F3F), Color(0xFF4A342E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 30),
                    SizedBox(height: 8),
                    Text("Find a Lawyer",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _smallCard("My Calendar", Icons.calendar_today, const Color(0xFF8D7B68))),
                  const SizedBox(width: 12),
                  Expanded(child: _smallCard("Messages", Icons.chat, const Color(0xFFC48A6A))),
                ],
              ),

              const SizedBox(height: 20),

              const Text("Recent Cases",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _caseItem("Property Dispute", "Adv Ahmed Khan", "In Progress"),
              _caseItem("Contract Review", "Adv Sarah Ali", "Completed"),
              _caseItem("Legal Consultation", "Adv Bilal Ahmed", "Scheduled"),
            ],
          ),
        ),
      ),
    );
  }

  // ── CASES PAGE ─────────────────────────────────────────
  Widget _casesPage() {
    return const SafeArea(
      child: Center(
        child: Text("My Cases", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── MESSAGES PAGE ──────────────────────────────────────
  Widget _messagesPage() {
    return const SafeArea(
      child: Center(
        child: Text("Messages", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── PROFILE PAGE ───────────────────────────────────────
  Widget _profilePage(String userName) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF6B4F3F),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Client", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                GetStorage().erase();
                // Get.offAllNamed(AppRoutes.login); // uncomment after import
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPER WIDGETS ─────────────────────────────────────
  Widget _smallCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _caseItem(String title, String lawyer, String status) {
    Color statusColor = status == "Completed"
        ? Colors.green
        : status == "In Progress"
            ? Colors.orange
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(lawyer, style: const TextStyle(color: Colors.grey)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}