import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/addlawyer.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/admin_dashboard.dart';

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
  int _getStatus(dynamic status) {
  if (status == null) return -1;
  if (status is int) return status;
  return int.tryParse(status.toString()) ?? -1;
}

  @override
  void initState() {
    super.initState();
    _lawyerService = LawyerService();
    _loadLawyers();
  }

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

  Future<void> _deleteLawyer(int id) async {
    try {
      await _lawyerService.deleteLawyer(id);

      _loadLawyers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lawyer deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editLawyer(int id) async {
  final lawyer = _lawyers.firstWhere((l) => l['id'] == id);
  final nameController = TextEditingController(text: lawyer['name']);
  final specController = TextEditingController(text: lawyer['specialization']);

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Lawyer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: specController, decoration: const InputDecoration(labelText: 'Specialization')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await _lawyerService.updateLawyer(
              id: id,
              name: nameController.text,
              email: lawyer['email'] ?? '',
              password: lawyer['password'] ?? '',
              specialization: specController.text,
              location: lawyer['location'] ?? '',
              experience: lawyer['experience'].toString(),
              cases: lawyer['cases'].toString(),
              rating: lawyer['rating'].toString(),
              status: lawyer['status'].toString(),
            );
            _loadLawyers();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

  Future<void> _approveLawyer(int index) async {
    final id = _lawyers[index]["id"];
    try {
      await _lawyerService.approveLawyer(id);
      setState(() {
        _lawyers[index]["status"] = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lawyer approved ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _disapproveLawyer(int index) async {
    final id = _lawyers[index]["id"];
    try {
      await _lawyerService.disapproveLawyer(id);
      setState(() {
        _lawyers[index]["status"] = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lawyer rejected ❌"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            );
          },
        ),

        title: const Text(
          "List of Lawyers",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLawyerPage()),
              ).then((_) => _loadLawyers());
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error: $_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadLawyers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_lawyers.isEmpty) {
      return const Center(child: Text('No lawyers found.'));
    }

    return ListView.builder(
      itemCount: _lawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _lawyers[index];
        final status = _getStatus(lawyer["status"]);

        final isApproved = status == 1;
        final isRejected = status == 0;

        // ── Brown color — same as app theme ──────────
        const brownColor = Colors.brown;

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
              // ── Header ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Text(
                      (lawyer["name"] ?? "").isNotEmpty
                          ? lawyer["name"][0]
                          : "?",
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

              // ── Details ────────────────────────────
              Text(
                (lawyer["name"] ?? "").isNotEmpty ? lawyer["name"][0] : "?",
                style: const TextStyle(color: Colors.white),
              ),
              Text((lawyer["id"]).toString() ?? ""),
              Text(lawyer["specialization"] ?? ""),
              Text("📍 ${lawyer["location"] ?? ""}"),
              Text("${lawyer["experience"] ?? ""} years experience"),
              Text("${lawyer["cases"] ?? ""} cases"),
              const SizedBox(height: 10),

              // ── Status Badge ───────────────────────
              if (status != -1)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isApproved ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    isApproved ? "✅ Approved" : "❌ Rejected",
                    style: TextStyle(
                      color: isApproved
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

              // ── Approve / Reject Toggle Buttons ────
              Row(
                children: [
                  // ── APPROVE BUTTON ────────────────
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        // brown jab approved, white jab nahi
                        backgroundColor: isApproved ? brownColor : Colors.white,
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Approve",
                        style: TextStyle(
                          // white text jab selected, brown jab nahi
                          color: isApproved ? Colors.white : brownColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── REJECT BUTTON ─────────────────
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _disapproveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        // brown jab rejected, white jab nahi
                        backgroundColor: isRejected ? brownColor : Colors.white,
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Reject",
                        style: TextStyle(
                          // white text jab selected, brown jab nahi
                          color: isRejected ? Colors.white : brownColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _editLawyer(lawyer['id']),
                      style: ElevatedButton.styleFrom(
                        // brown jab approved, white jab nahi
                        backgroundColor: isApproved ? brownColor : Colors.white,
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteLawyer(lawyer['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.brown),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
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
