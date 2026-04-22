import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/screens/dashboard_screen/addlawyer.dart';


class Managelawyers extends StatefulWidget {
  const Managelawyers({super.key});

  @override
  State<Managelawyers> createState() => _ManagelawyersState();
}

class _ManagelawyersState extends State<Managelawyers> {
  // Fix: declare as typed fields, not inferred
  late final LawyerService _lawyerService;
  late Future<List<Map<String, dynamic>>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    _lawyerService = LawyerService(); // initialize here, not in field declaration
    _lawyersFuture = _lawyerService.fetchLawyers();
  }
  // ... rest of the class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Lawyers"),
        backgroundColor: const Color(0xFF6B4F3F),
        titleTextStyle: const TextStyle(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLawyerPage()),
              ).then((_) {
                // Refresh list after returning from AddLawyerPage
                setState(() {
                  _lawyersFuture = _lawyerService.fetchLawyers();
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lawyersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lawyersFuture = _lawyerService.fetchLawyers();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final lawyers = snapshot.data ?? [];

          if (lawyers.isEmpty) {
            return const Center(child: Text('No lawyers found.'));
          }

          return ListView.builder(
            itemCount: lawyers.length,
            itemBuilder: (context, index) {
              final lawyer = lawyers[index];

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.brown,
                          child: Text(
                            (lawyer["name"] ?? "?")[0],
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                lawyer["status"] =
                                    lawyer["status"] == "approved"
                                        ? ""
                                        : "approved";
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
                                lawyer["status"] =
                                    lawyer["status"] == "rejected"
                                        ? ""
                                        : "rejected";
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
          );
        },
      ),
    );
  }
}