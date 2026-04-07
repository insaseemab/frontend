import 'package:flutter/material.dart';

class ApproveLawyerScreen extends StatelessWidget {
  const ApproveLawyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> lawyers = [
      {
        "name": "Ahmad Khan",
        "specialization": "Civil Law",
        "city": "Lahore",
        "experience": "15 years",
        "cases": "250",
        "rating": "4.9"
      },
      {
        "name": "Sarah Ali",
        "specialization": "Corporate Law",
        "city": "Karachi",
        "experience": "10 years",
        "cases": "180",
        "rating": "4.8"
      },
      {
        "name": "Bilal Ahmed",
        "specialization": "Criminal Law",
        "city": "Islamabad",
        "experience": "12 years",
        "cases": "200",
        "rating": "4.7"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Insaaf Connect"),
        backgroundColor: Color(0xFFF5EFE6),
      ),
      body: ListView.builder(
        itemCount: lawyers.length,
        itemBuilder: (context, index) {
          final lawyer = lawyers[index];

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Text(
                        lawyer["name"][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "⭐ ${lawyer["rating"] ?? ""}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Adv. ${lawyer["name"] ?? ""}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),

                Text(lawyer["specialization"] ?? ""),
                Text("📍 ${lawyer["city"] ?? ""}"),
                Text("${lawyer["experience"] ?? ""} experience"),
                Text("${lawyer["cases"] ?? ""} cases"),

                const SizedBox(height: 10),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Approved")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("Approve"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Rejected")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}