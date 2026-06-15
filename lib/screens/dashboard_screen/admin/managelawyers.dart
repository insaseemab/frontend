import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/routes/app_routes.dart';
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

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _deleteLawyer(int id) async {
    // Show confirmation dialog first
    final confirmed = await Get.dialog(
      AlertDialog(
        title: const Text('Delete Lawyer'),
        content: const Text('Are you sure you want to delete this lawyer?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _lawyerService.deleteLawyer(id);
      if (!mounted) return;
      _loadLawyers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lawyer deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── EDIT ──────────────────────────────────────────────────────────────────
  Future<void> _editLawyer(Map<String, dynamic> lawyer) async {
    final nameController = TextEditingController(
      text: lawyer['name']?.toString() ?? '',
    );
    final specController = TextEditingController(
      text: lawyer['specialization']?.toString() ?? '',
    );
    final locationController = TextEditingController(
      text: lawyer['location']?.toString() ?? '',
    );
    final experienceController = TextEditingController(
      text: lawyer['experience']?.toString() ?? '',
    );
    final casesController = TextEditingController(
      text: lawyer['cases']?.toString() ?? '',
    );

    await Get.dialog(
      AlertDialog(
        title: const Text(
          'Edit Lawyer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: specController,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: casesController,
                decoration: const InputDecoration(labelText: 'Cases'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              try {
                await _lawyerService.updateLawyer(
                  id: lawyer['id'],
                  name: nameController.text.trim(),
                  email: lawyer['email']?.toString() ?? '',
                  password: lawyer['password']?.toString() ?? '',
                  specialization: specController.text.trim(),
                  location: locationController.text.trim(),
                  experience: experienceController.text.trim(),
                  cases: casesController.text.trim(),
                  rating: lawyer['rating']?.toString() ?? '0',
                  status: lawyer['status']?.toString() ?? '1',
                );
                if (!mounted) return;
                _loadLawyers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lawyer updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── APPROVE ───────────────────────────────────────────────────────────────
  Future<void> _approveLawyer(int index) async {
    final id = _lawyers[index]['id'];
    try {
      await _lawyerService.approveLawyer(id);
      if (!mounted) return;
      setState(() {
        _lawyers[index]['status'] = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lawyer approved ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── DISAPPROVE ────────────────────────────────────────────────────────────
  Future<void> _disapproveLawyer(int index) async {
    final id = _lawyers[index]['id'];
    try {
      await _lawyerService.disapproveLawyer(id);
      if (!mounted) return;
      setState(() {
        _lawyers[index]['status'] = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lawyer rejected ❌'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () {
              Get.offAll(() => AdminDashboardScreen());
            },
          ),
        ),
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "List of Lawyers",
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.brown),
            onPressed: () async {
              await Get.toNamed(AppRoutes.addLawyer);
              _loadLawyers();
            },
          ),
        ],
      ),
      // <-- ADD THIS
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
        final status = _getStatus(lawyer['status']);
        final isApproved = status == 1;
        final isRejected = status == 0;

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
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Text(
                      (lawyer['name'] ?? '').isNotEmpty
                          ? lawyer['name'][0].toUpperCase()
                          : '?',
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
                      '⭐ ${lawyer["rating"] ?? ""}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Details ──────────────────────────────────────────────────
              Text(
                lawyer['name']?.toString() ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'ID: ${lawyer["id"]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(lawyer['specialization']?.toString() ?? ''),
              Text('📍 ${lawyer["location"] ?? ""}'),
              Text('${lawyer["experience"] ?? ""} years experience'),
              Text('${lawyer["cases"] ?? ""} cases'),
              const SizedBox(height: 10),

              // ── Status Badge ─────────────────────────────────────────────
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
                    isApproved ? '✅ Approved' : '❌ Rejected',
                    style: TextStyle(
                      color: isApproved
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

              // ── Approve / Reject Row ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApproved ? brownColor : Colors.white,
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Approve',
                        style: TextStyle(
                          color: isApproved ? Colors.white : brownColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _disapproveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRejected ? brownColor : Colors.white,
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: isRejected ? Colors.white : brownColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Edit / Delete Row ────────────────────────────────────────
              // FIX: Edit button now has its OWN fixed style, not tied to isApproved
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editLawyer(lawyer),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // always white
                        foregroundColor: brownColor, // always brown text/icon
                        side: const BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteLawyer(lawyer['id']),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // always white
                        foregroundColor: Colors.red, // always red text/icon
                        side: const BorderSide(color: Colors.red),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
