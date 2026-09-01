import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/routes/app_routes.dart';

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
        title: Text('Delete Lawyer', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete this lawyer?',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: AppTextStyles.label.copyWith(color: AppColors.Brown)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: AppTextStyles.label.copyWith(color: AppColors.error)),
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
        SnackBar(
          content: const Text('Lawyer deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
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
        title: Text('Edit Lawyer', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(labelText: 'Name', labelStyle: AppTextStyles.labelMuted),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: specController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(labelText: 'Specialization', labelStyle: AppTextStyles.labelMuted),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(labelText: 'Location', labelStyle: AppTextStyles.labelMuted),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: experienceController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(labelText: 'Experience', labelStyle: AppTextStyles.labelMuted),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: casesController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(labelText: 'Cases', labelStyle: AppTextStyles.labelMuted),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.label.copyWith(color: AppColors.Brown)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.Brown,
              foregroundColor: AppColors.white,
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
                  SnackBar(
                    content: const Text('Lawyer updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('Save', style: AppTextStyles.button),
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
        SnackBar(
          content: const Text('Lawyer approved ✅'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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
        SnackBar(
          content: const Text('Lawyer rejected ❌'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // ── RENEW ─────────────────────────────────────────────────────────────────
  Future<void> _renewLawyer(int index) async {
    final id = _lawyers[index]['id'];
    try {
      await _lawyerService.renewLawyer(id);
      if (!mounted) return;
      _loadLawyers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Subscription renewed (30 Days) ✅'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text("List of Lawyers", style: AppTextStyles.heading2),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.Brown),
                    onPressed: () async {
                      await Get.toNamed(AppRoutes.addLawyer);
                      _loadLawyers();
                    },
                  ),
                ],
              ),
            ),
            // The rest of your page content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.Brown));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Error: $_errorMessage', textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadLawyers,
              style: AppButtonStyles.primary.copyWith(
                minimumSize: WidgetStateProperty.all(const Size(140, 44)),
              ),
              child: Text('Retry', style: AppTextStyles.button),
            ),
          ],
        ),
      );
    }

    if (_lawyers.isEmpty) {
      return Center(child: Text('No lawyers found.', style: AppTextStyles.bodyLarge));
    }

    return ListView.builder(
      itemCount: _lawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _lawyers[index];
        final status = _getStatus(lawyer['status']);
        final isApproved = status == 1;
        final isRejected = status == 0;

        final brownColor = AppColors.Brown;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.Brown.withOpacity(0.10),
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
                    backgroundColor: AppColors.Brown,
                    child: Text(
                      (lawyer['name'] ?? '').isNotEmpty
                          ? lawyer['name'][0].toUpperCase()
                          : '?',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ ${lawyer["rating"] ?? ""}',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Details ──────────────────────────────────────────────────
              Text(
                lawyer['name']?.toString() ?? 'Unknown',
                style: AppTextStyles.heading4.copyWith(fontSize: 16),
              ),
              Text(
                'ID: ${lawyer["id"]}',
                style: AppTextStyles.bodySmall,
              ),
              Text(lawyer['specialization']?.toString() ?? '', style: AppTextStyles.bodyMedium),
              Text('📍 ${lawyer["location"] ?? ""}', style: AppTextStyles.bodyMedium),
              Text('${lawyer["experience"] ?? ""} years experience', style: AppTextStyles.bodyMedium),
              Text('${lawyer["cases"] ?? ""} cases', style: AppTextStyles.bodyMedium),
              if (lawyer["subscription_expiry"] != null)
                Text(
                  'Expires: ${lawyer["subscription_expiry"].toString().split("T")[0]}',
                  style: AppTextStyles.label,
                ),
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
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isApproved ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Text(
                    isApproved ? '✅ Approved' : '❌ Rejected',
                    style: TextStyle(
                      color: isApproved ? AppColors.success : AppColors.error,
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
                        backgroundColor: isApproved ? brownColor : AppColors.white,
                        side: BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Approve',
                        style: AppTextStyles.label.copyWith(
                          color: isApproved ? AppColors.white : brownColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _disapproveLawyer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRejected ? brownColor : AppColors.white,
                        side: BorderSide(color: brownColor),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: AppTextStyles.label.copyWith(
                          color: isRejected ? AppColors.white : brownColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Edit / Delete Row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editLawyer(lawyer),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text('Edit', style: AppTextStyles.label.copyWith(color: brownColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: brownColor,
                        side: BorderSide(color: brownColor),
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
                      icon: Icon(Icons.delete, size: 16, color: AppColors.error),
                      label: Text('Delete', style: AppTextStyles.label.copyWith(color: AppColors.error)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Renew Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _renewLawyer(index),
                  icon: Icon(Icons.autorenew, size: 16, color: brownColor),
                  label: Text('Renew (30 Days)', style: AppTextStyles.label.copyWith(color: brownColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: brownColor,
                    side: BorderSide(color: brownColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}