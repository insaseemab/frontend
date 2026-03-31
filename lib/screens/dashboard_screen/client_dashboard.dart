import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final box = GetStorage();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userName = box.read('userName') ?? "Ali";

    final List<Widget> pages = [
      homePage(userName),
      const Center(child: Text("Approve Lawyer Screen")),
      const Center(child: Text("View Cases Screen")),
      const Center(child: Text("Admin Profile Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      /// 🔹 BODY CHANGE ON TAB
      body: pages[currentIndex],

      /// 🔹 BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF6B4F3F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: "Approve lawyer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /// ================= HOME PAGE =================
  Widget homePage(String userName) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Insaaf Connect",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none),
                      SizedBox(width: 12),
                      Icon(Icons.person_outline),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// GREETING
              Text(
                "Welcome Back, $userName!",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              const Text(
                "Here’s what’s happening with your legal matters",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// QUICK ACTIONS
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
                child: Column(
                  children: const [
                    Icon(Icons.search, color: Colors.white, size: 30),
                    SizedBox(height: 8),
                    Text("Find a Lawyer",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: smallCard("My Calendar", Icons.calendar_today,
                        const Color(0xFF8D7B68)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: smallCard(
                        "Messages", Icons.chat, const Color(0xFFC48A6A)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// CASES
              const Text("Recent Cases",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              caseItem("Property Dispute", "Adv Ahmed Khan", "In Progress"),
              caseItem("Contract Review", "Adv Sarah Ali", "Completed"),
              caseItem("Legal Consultation", "Adv Bilal Ahmed", "Scheduled"),
            ],
          ),
        ),
      ),
    );
  }

  /// SMALL CARD
  Widget smallCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// CASE ITEM
  Widget caseItem(String title, String lawyer, String status) {
    Color statusColor;

    if (status == "Completed") {
      statusColor = Colors.green;
    } else if (status == "In Progress") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(lawyer, style: const TextStyle(color: Colors.grey)),
          ]),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status,
                style: TextStyle(color: statusColor, fontSize: 12)),
          )
        ],
      ),
    );
  }
}