import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insaafconnect/screens/dashboard_screen/admin/createcase.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/admin_dashboard.dart';
import 'package:get_storage/get_storage.dart';

const String baseUrl = 'http://localhost:3000';

class CaseModel {
  final int id;
  final String caseType;
  final String clientName;
  final String lawyerName;
  final String caseStatus;
  final String paymentStatus;
  final String hearingDate;

  CaseModel({
    required this.id,
    required this.caseType,
    required this.clientName,
    required this.lawyerName,
    required this.caseStatus,
    required this.paymentStatus,
    required this.hearingDate,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      caseType: json['case_type']?.toString() ?? 'Unknown',
      clientName: json['name']?.toString() ?? 'N/A',
      lawyerName: json['lawyer_id']?.toString() ?? 'N/A',
      caseStatus: json['case_status']?.toString() ?? 'Unknown',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      hearingDate: json['hearing_date']?.toString() ?? 'N/A',
    );
  }
}

class CaseApiService {
  // GET ALL CASES
  static Future<List<CaseModel>> fetchAllCases() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cases'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => CaseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cases: ${response.statusCode}');
    }
  }

  // DELETE CASE
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

  // UPDATE STATUS
  static Future<void> updateCaseStatus(int caseId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/cases/$caseId/status/$newStatus'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({'case_status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }
}

class ManageCasesPage extends StatefulWidget {
  const ManageCasesPage({super.key});

  @override
  State<ManageCasesPage> createState() => _ManageCasesPageState();
}

class _ManageCasesPageState extends State<ManageCasesPage> {
  List<CaseModel> allCases = [];

  bool isLoading = true;

  String? errorMessage;

  String selectedFilter = 'All';

  String searchQuery = '';

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
      final cases = await CaseApiService.fetchAllCases();

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

  Future<void> _deleteCase(CaseModel c) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (ctx) => AlertDialog(
        title: const Text('Delete Case'),

        content: Text('Are you sure you want to delete case #${c.id}?'),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),

            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),

            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final box = GetStorage();

        String token = box.read('token') ?? '';

        await CaseApiService.deleteCase(c.id, token);

        _loadCases();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateStatus(CaseModel c, String newStatus) async {
    try {
      await CaseApiService.updateCaseStatus(c.id, newStatus);

      _loadCases();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(
        backgroundColor: Colors.brown,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        ),

        title: const Text(
          'List of Cases',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),

            onPressed: () async {
              final result = await Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const CreateCasePage()),
              );

              if (result == true) {
                _loadCases();
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCases,
          ),
        ],
      ),

      body: Container(
        color: const Color(0xFFF5F0EB),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),

              child: Text(
                'Case Management',

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                'View and manage all cases',

                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            _buildStatsRow(),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: TextField(
                onChanged: (v) {
                  setState(() {
                    searchQuery = v;
                  });
                },

                decoration: InputDecoration(
                  hintText: 'Search by case ID or client',

                  prefixIcon: const Icon(Icons.search),

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

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

                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xFF5D4037)
                                  : Colors.white,

                              foregroundColor: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                            ),

                            child: Text(filter),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildTableHeader(),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (filteredCases.isEmpty) {
      return const Center(child: Text('No cases found'));
    }

    return ListView.builder(
      itemCount: filteredCases.length,

      itemBuilder: (_, index) {
        return _buildCaseRow(filteredCases[index]);
      },
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total', 'value': '${allCases.length}'},

      {'label': 'Approved', 'value': '$approvedCases'},

      {'label': 'Closed', 'value': '$closedCases'},

      {'label': 'Unpaid', 'value': '$pendingPayment'},
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),

            padding: const EdgeInsets.symmetric(vertical: 12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),

            child: Column(
              children: [
                Text(
                  stat['value']!,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  stat['label']!,

                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Expanded(
            flex: 2,
            child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Expanded(
            flex: 2,
            child: Text(
              'Lawyer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            flex: 1,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseRow(CaseModel c) {
    final isApproved = c.caseStatus.toLowerCase() == 'approved';

    final isClosed = c.caseStatus.toLowerCase() == 'closed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        children: [
          Expanded(flex: 1, child: Text('#${c.id}')),

          Expanded(
            flex: 2,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  c.caseType,

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                Text(
                  c.clientName,

                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          Expanded(flex: 2, child: Text(c.lawyerName)),

          Expanded(
            flex: 2,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

              decoration: BoxDecoration(
                color: isApproved
                    ? Colors.green.shade100
                    : isClosed
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                c.caseStatus,

                style: TextStyle(
                  fontSize: 11,

                  color: isApproved
                      ? Colors.green.shade800
                      : isClosed
                      ? Colors.blue.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,

            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),

              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCase(c);
                } else {
                  _updateStatus(c, value);
                }
              },

              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'approved',
                  child: Text('Set Approved'),
                ),

                const PopupMenuItem(
                  value: 'pending',
                  child: Text('Set Pending'),
                ),

                const PopupMenuItem(
                  value: 'rejected',
                  child: Text('Set Rejected'),
                ),

                const PopupMenuItem(
                  value: 'hearing',
                  child: Text('Set Hearing'),
                ),

                const PopupMenuItem(value: 'closed', child: Text('Set Closed')),

                const PopupMenuDivider(),

                const PopupMenuItem(
                  value: 'delete',

                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
