import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/routes/app_routes.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/edit_case.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/config/environment.dart';
import 'package:insaafconnect/core/utils/theme.dart'; 

const String baseUrl = Environment.apiBaseUrl;

class CaseModel {
  final int id;
  final String caseType;
  final String clientName;
  final String lawyerId;
  final String lawyerName;
  final String caseStatus;
  final String paymentStatus;
  final String hearingDate;
  final String descriptionCase;
  final String phone;
  final String address;
  final String departConcern;
  final String caseStartDate;

  CaseModel({
    required this.id,
    required this.caseType,
    required this.clientName,
    required this.lawyerId,
    required this.lawyerName,
    required this.caseStatus,
    required this.paymentStatus,
    required this.hearingDate,
    required this.descriptionCase,
    required this.phone,
    required this.address,
    required this.departConcern,
    required this.caseStartDate,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      caseType: json['case_type']?.toString() ?? 'Unknown',
      clientName:
          json['client_name']?.toString() ?? json['name']?.toString() ?? '',
      lawyerId: json['lawyer_id']?.toString() ?? 'N/A', // ← fixed
      lawyerName: json['lawyer_name']?.toString() ?? '',
      caseStatus: json['case_status']?.toString() ?? 'Unknown',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      hearingDate: json['hearing_date']?.toString() ?? 'N/A',
      descriptionCase: json['description_case']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      departConcern: json['depart_concern']?.toString() ?? '',
      caseStartDate: json['case_start_date']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────
// CASE API SERVICE
// ─────────────────────────────────────────
class CaseApiService {
  static Future<List<CaseModel>> fetchAllCases() async {
    final box = GetStorage();
    final String token = box.read('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/cases'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CaseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cases: ${response.statusCode}');
    }
  }

  static Future<void> deleteCase(int caseId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cases/$caseId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete case: ${response.body}');
    }
  }

  static Future<void> updateCaseStatus(int caseId, String newStatus) async {
    final box = GetStorage();
    final String token = box.read('token') ?? '';

    final response = await http.patch(
      Uri.parse('$baseUrl/cases/$caseId/status/$newStatus'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  static Future<void> updateCase({
    required int id,
    required String name,
    required String caseType,
    required String caseStatus,
    required String descriptionCase,
    required String phone,
    required String address,
    required String caseStartDate,
    required String departConcern,
    required String hearingDate,
    required int paymentStatus,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cases/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": name,
        "case_type": caseType,
        "case_status": caseStatus,
        "description_case": descriptionCase,
        "phone": phone,
        "address": address,
        "case_start_date": caseStartDate,
        "depart_concern": departConcern,
        "hearing_date": hearingDate,
        "payment_status": paymentStatus,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update case: ${response.body}');
    }
  }
}

// ─────────────────────────────────────────
// MANAGE CASES PAGE
// ─────────────────────────────────────────
class ManageCasesPage extends StatefulWidget {
  final String userRole;
  const ManageCasesPage({super.key, this.userRole = 'admin'});

  @override
  State<ManageCasesPage> createState() => _ManageCasesPageState();
}

class _ManageCasesPageState extends State<ManageCasesPage> {
  List<CaseModel> allCases = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'All';
  String searchQuery = '';
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      List<CaseModel> cases;

      final String role = box.read('role') ?? 'client';
      final String token = box.read('token') ?? '';

      if (role == 'admin') {
        cases = await CaseApiService.fetchAllCases();
      } else {
        final raw = await CasesService.fetchMyCases(token);
        cases = raw.map((json) => CaseModel.fromJson(json)).toList();
      }

      setState(() {
        allCases = cases;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _openEditDialog(CaseModel c) async {
    final result = await Get.dialog(EditCaseDialog(caseData: c));
    if (!mounted) return;
    if (result == true) {
      _loadCases();
    }
  }

  void _viewCaseDetail(CaseModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Case #${c.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailLine('Case Type', c.caseType),
                _detailLine('Client', c.clientName),
                _detailLine('Lawyer', c.lawyerName),
                _detailLine('Status', c.caseStatus),
                _detailLine('Payment Status', c.paymentStatus),
                _detailLine('Hearing Date', c.hearingDate),
                _detailLine('Start Date', c.caseStartDate),
                _detailLine('Phone', c.phone),
                _detailLine('Address', c.address),
                _detailLine('Department/Concern', c.departConcern),
                if (c.descriptionCase.isNotEmpty)
                  _detailLine('Description', c.descriptionCase),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCase(CaseModel c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Case'),
        content: Text('Are you sure you want to delete case #${c.id}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final String token = box.read('token') ?? '';
        await CaseApiService.deleteCase(c.id, token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case deleted successfully')),
        );
        _loadCases();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateStatus(CaseModel c, String newStatus) async {
    try {
      await CaseApiService.updateCaseStatus(c.id, newStatus);
      setState(() {
        final index = allCases.indexWhere((x) => x.id == c.id);
        if (index != -1) {
          allCases[index] = CaseModel(
            id: c.id,
            caseType: c.caseType,
            clientName: c.clientName,
            lawyerId: c.lawyerId,
            lawyerName: c.lawyerName,
            caseStatus: newStatus,
            paymentStatus: c.paymentStatus,
            hearingDate: c.hearingDate,
            descriptionCase: c.descriptionCase,
            phone: c.phone,
            address: c.address,
            departConcern: c.departConcern,
            caseStartDate: c.caseStartDate,
          );
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'closed':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      case 'hearing':
        return Colors.purple.shade800; // no theme equivalent
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  List<CaseModel> get filteredCases {
    return allCases.where((c) {
      final matchesFilter =
          selectedFilter == 'All' ||
          c.caseStatus.toLowerCase() == selectedFilter.toLowerCase();
      final q = searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          c.id.toString().contains(q) ||
          c.clientName.toLowerCase().contains(q) ||
          c.lawyerName.toLowerCase().contains(q) ||
          c.caseType.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get approvedCases =>
      allCases.where((c) => c.caseStatus.toLowerCase() == 'approved').length;

  int get closedCases =>
      allCases.where((c) => c.caseStatus.toLowerCase() == 'closed').length;

  int get pendingPayment =>
      allCases.where((c) => c.paymentStatus.toLowerCase() == 'unpaid').length;

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
                    child: Text(
                      "Case Management",
                      style: AppTextStyles.heading3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.Brown),
                    onPressed: _loadCases,
                  ),
                  
                  if (['admin', 'lawyer'].contains(box.read('role') ?? 'client'))
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.Brown),
                      onPressed: () async {
                        final result = await Get.toNamed(AppRoutes.createCase);
                        if (result == true) {
                          _loadCases();
                        }
                      },
                    ),
                ],
              ),
            ),

            // ── Stat cards row (matches appointments page) ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _statCard('${allCases.length}', 'Total'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      '$approvedCases',
                      'Approved',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      '$closedCases',
                      'Closed',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      '$pendingPayment',
                      'Unpaid',
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by case ID or client',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter pills ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        'All',
                        'Approved',
                        'Pending',
                        'Rejected',
                        'Hearing',
                        'Closed',
                      ].map((filter) {
                        final isSelected = selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => selectedFilter = filter),
                            selectedColor: AppColors.Brown,
                            backgroundColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide.none,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.Brown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.Brown));
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (filteredCases.isEmpty) {
      return const Center(child: Text('No cases found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filteredCases.length,
      itemBuilder: (_, index) => _buildCaseCard(filteredCases[index]),
    );
  }

  Widget _buildActionsForRole(CaseModel c) {
    final String role = box.read('role') ?? 'client';

    if (role == 'admin') {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: AppColors.Brown),
        onSelected: (value) {
          if (value == 'delete') {
            _deleteCase(c);
          } else if (value == 'edit') {
            _openEditDialog(c);
          } else if (value == 'view') {
            _viewCaseDetail(c);
          } else {
            _updateStatus(c, value);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'view', child: Text('View Detail')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'approved', child: Text('Set Approved')),
          const PopupMenuItem(value: 'pending', child: Text('Set Pending')),
          const PopupMenuItem(value: 'rejected', child: Text('Set Rejected')),
          const PopupMenuItem(value: 'hearing', child: Text('Set Hearing')),
          const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit Case', style: TextStyle(color: AppColors.info)),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      );
    }

    if (role == 'lawyer') {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: AppColors.Brown),
        onSelected: (value) {
          if (value == 'delete') {
            _deleteCase(c);
          } else if (value == 'edit') {
            _openEditDialog(c);
          } else if (value == 'view') {
            _viewCaseDetail(c);
          } else {
            _updateStatus(c, value);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'view', child: Text('View Detail')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'pending', child: Text('Set Pending')),
          const PopupMenuItem(value: 'hearing', child: Text('Set Hearing')),
          const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit Case', style: TextStyle(color: AppColors.info)),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      );
    }

    // Client (or unknown role): view-only.
    return IconButton(
      icon: Icon(Icons.visibility_outlined, color: AppColors.Brown),
      onPressed: () => _viewCaseDetail(c),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.Brown),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  ),
                  Text(
                    value.isEmpty ? '-' : value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.iconMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseCard(CaseModel c) {
    final statusColor = _statusColor(c.caseStatus);
    final isUnpaid = c.paymentStatus.toLowerCase() == 'unpaid';

    return GestureDetector(
      onTap: () => _viewCaseDetail(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Case #${c.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.Brown,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.caseStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                _buildActionsForRole(c),
              ],
            ),
            const SizedBox(height: 10),

            // ── client / lawyer info tiles ────────────────────────
            Row(
              children: [
                _infoTile(Icons.person_outline, 'Client', c.clientName),
                const SizedBox(width: 10),
                _infoTile(Icons.gavel_outlined, 'Lawyer', c.lawyerName),
              ],
            ),
            const SizedBox(height: 10),

            // ── case type / hearing date / payment status ────────
            _detailRow(Icons.folder_outlined, '${c.caseType}'),
            const SizedBox(height: 6),
            _detailRow(Icons.event_outlined, 'Hearing: ${c.hearingDate}'),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isUnpaid ? Icons.error_outline : Icons.check_circle_outline,
                  size: 15,
                  color: isUnpaid ? AppColors.error : AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Payment: ${c.paymentStatus}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isUnpaid ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (c.descriptionCase.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                c.descriptionCase,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}