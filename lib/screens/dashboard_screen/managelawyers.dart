import 'package:flutter/material.dart';
import 'package:insaafconnect/screens/dashboard_screen/addlawyer.dart';

class Managelawyers extends StatefulWidget {
  const Managelawyers({super.key});

  @override
  State<Managelawyers> createState() => _ManagelawyersState();
}

class _ManagelawyersState extends State<Managelawyers> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> lawyers = [
      {
        "name": "Ahmad Khan",
        "specialization": "Civil Law",
        "city": "Lahore",
        "experience": "15 years",
        "cases": "250",
        "rating": "4.9",
      },
      {
        "name": "Sarah Ali",
        "specialization": "Corporate Law",
        "city": "Karachi",
        "experience": "10 years",
        "cases": "180",
        "rating": "4.8",
      },
      {
        "name": "Bilal Ahmed",
        "specialization": "Criminal Law",
        "city": "Islamabad",
        "experience": "12 years",
        "cases": "200",
        "rating": "4.7",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Lawyers"),
        backgroundColor: Color(0xFF6B4F3F),
        titleTextStyle: TextStyle(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLawyerPage()),
              );
            },
          ),
        ],
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
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "⭐ ${lawyer["rating"] ?? ""}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Adv. ${lawyer["name"] ?? ""}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(lawyer["specialization"] ?? ""),
                Text("📍 ${lawyer["city"] ?? ""}"),
                Text("${lawyer["experience"] ?? ""} experience"),
                Text("${lawyer["cases"] ?? ""} cases"),

                const SizedBox(height: 10),

                // Buttons Row
                // managelawyers.dart
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (lawyer["status"] == "approved") {
                              lawyer["status"] = "";
                            } else {
                              lawyer["status"] = "approved";
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lawyer["status"] == "approved"
                              ? const Color(0xFF6B4F3F)
                              : Colors.grey, 
                        ),
                        child: const Text(
                          "Approve",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (lawyer["status"] == "rejected") {
                              lawyer["status"] = "";
                            } else {
                              lawyer["status"] = "rejected";
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lawyer["status"] == "rejected"
                              ? const Color(0xFF6B4F3F) 
                              : Colors.grey, 
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
