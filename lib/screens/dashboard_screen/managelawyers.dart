import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/screens/dashboard_screen/addlawyer.dart';

class Managelawyers extends StatefulWidget {
  const Managelawyers({super.key});

  @override
  State<Managelawyers> createState() => _ManagelawyersState();
}

class _ManagelawyersState extends State<Managelawyers> {
  late final LawyerService _lawyerService;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _lawyers = [];

  @override
  void initState() {
    super.initState();
    _lawyerService = LawyerService();
    _loadLawyers();
  }

  // ── Fetch lawyers and store in state ──────────────────
  Future<void> _loadLawyers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _lawyerService.fetchLawyers();
      setState(() {
        _lawyers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Approve ───────────────────────────────────────────
  Future<void> _approveLawyer(int index) async {
    final id = _lawyers[index]["id"];
    try {
      await _lawyerService.approveLawyer(id);
      setState(() {
        _lawyers[index]["status"] = "approved"; // index-based = reliable
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lawyer approved ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Disapprove ────────────────────────────────────────
  Future<void> _disapproveLawyer(int index) async {
    final id = _lawyers[index]["id"];
    try {
      await _lawyerService.disapproveLawyer(id);
      setState(() {
        _lawyers[index]["status"] = "rejected"; // index-based = reliable
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lawyer rejected ❌"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              ).then((_) => _loadLawyers()); // refresh after add
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Loading ───────────────────────────────────────
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Error ─────────────────────────────────────────
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadLawyers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ── Empty ─────────────────────────────────────────
    if (_lawyers.isEmpty) {
      return const Center(child: Text('No lawyers found.'));
    }

    // ── List ──────────────────────────────────────────
    return ListView.builder(
      itemCount: _lawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _lawyers[index];
        final status = lawyer["status"]?.toString() ?? "";

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
              // ── Header row ─────────────────────────
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

              // ── Lawyer details ─────────────────────
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

              // ── Status Badge ───────────────────────
              if (status.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == "approved"
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: status == "approved" ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    status == "approved" ? "✅ Approved" : "❌ Rejected",
                    style: TextStyle(
                      color: status == "approved"
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

              // ── Approve / Reject Buttons ───────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: status == "approved"
                          ? null
                          : () => _approveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == "approved"
                            ? Colors.green
                            : const Color(0xFF6B4F3F),
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
                      onPressed: status == "rejected"
                          ? null
                          : () => _disapproveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == "rejected"
                            ? Colors.red
                            : Colors.white,
                        side: const BorderSide(color: Color(0xFF6B4F3F)),
                      ),
                      child: Text(
                        "Reject",
                        style: TextStyle(
                          color: status == "rejected"
                              ? Colors.white
                              : const Color(0xFF6B4F3F),
                        ),
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
  }
}