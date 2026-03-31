import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LawyerDashboard extends StatelessWidget {
  LawyerDashboard({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userName = box.read('userName') ?? "Ahmed Khan";

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 HEADER
                const Text(
                  "Insaaf Connect",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                /// 🔹 WELCOME
                Text(
                  "Welcome, Adv. $userName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "You have 3 appointments scheduled for today",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// 🔹 STATS
                Row(
                  children: [
                    Expanded(child: statCard("Active Cases", "12")),
                    const SizedBox(width: 10),
                    Expanded(child: statCard("Appointments", "3")),
                    const SizedBox(width: 10),
                    Expanded(child: statCard("Messages", "8")),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔹 QUICK ACTIONS
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: actionCard(
                        "Appointment Requests",
                        Icons.request_page,
                        const Color(0xFFC48A6A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: actionCard(
                        "View Calendar",
                        Icons.calendar_today,
                        const Color(0xFF6B4F3F),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: actionCard(
                        "Messages",
                        Icons.chat,
                        const Color(0xFF8FA78A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔹 ACTIVE CASES + SCHEDULE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LEFT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Active Cases",
                              style: TextStyle(fontWeight: FontWeight.bold)),

                          const SizedBox(height: 10),

                          caseItem("Property Dispute", "High"),
                          caseItem("Contract Review", "Medium"),
                          caseItem("Legal Consultation", "Low"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// RIGHT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Schedule",
                              style: TextStyle(fontWeight: FontWeight.bold)),

                          const SizedBox(height: 10),

                          scheduleItem("10:00 AM", "Court Hearing"),
                          scheduleItem("2:00 PM", "Client Meeting"),
                          scheduleItem("4:00 PM", "Document Review"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 STAT CARD
  Widget statCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6DED3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 🔹 ACTION CARD
  Widget actionCard(String title, IconData icon, Color color) {
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
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 🔹 CASE ITEM
  Widget caseItem(String title, String priority) {
    Color color;

    if (priority == "High") {
      color = Colors.red;
    } else if (priority == "Medium") {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              priority,
              style: TextStyle(color: color, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 SCHEDULE ITEM
  Widget scheduleItem(String time, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}