import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userName = box.read('userName') ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF6B4F3F),
        actions: [
          IconButton(
            onPressed: () {
              box.erase(); // logout
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 👋 Greeting
            Text(
              "Welcome, $userName 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Cards Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [

                  dashboardCard("Find Lawyer", Icons.search),
                  dashboardCard("My Cases", Icons.folder),
                  dashboardCard("Chat", Icons.chat),
                  dashboardCard("Appointments", Icons.calendar_today),

                ],
              ),
            ),
          ],
        ),
      ),

      /// 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF6B4F3F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// 🔹 Card Widget
  Widget dashboardCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Color(0xFF6B4F3F)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}