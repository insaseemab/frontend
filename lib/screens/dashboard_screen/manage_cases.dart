import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insaafconnect/screens/dashboard_screen/admin_dashboard.dart';

// ─── CHANGE THIS to your actual backend URL ──────────────────────────────────
const String baseUrl = 'http://localhost:3000';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INSAAF CONNECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D4037)),
        useMaterial3: true,
      ),
      home: const ManageCasesPage(),
    );
  }
}

// ─── Data Model (maps real DB columns) ──────────────────────────────────────
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
      clientName:
          json['name']?.toString() ??
          'N/A', // API uses 'name', not 'client_name'
      lawyerName:
          json['lawyer_id']?.toString() ??
          'N/A', // API returns lawyer_id, not name
      caseStatus: json['case_status']?.toString() ?? 'Unknown',
      paymentStatus:
          json['payment_status']?.toString() ??
          'unpaid', // ← THIS was the crash
      hearingDate: json['hearing_date']?.toString() ?? 'N/A',
    );
  }
}

// ─── API Service ─────────────────────────────────────────────────────────────
class CaseApiService {
  static Future<void> createCase({
  required String descriptionCase,
  required String clientId,
  required String lawyerId,
  required String phone,
  required String address,
  required String caseType,
  required String name,
  required String caseStartDate,
  required String caseStatus,
  required String departConcern,
  required String hearingDate,
  required String paymentStatus,
  required String token,
}) async {

  final response = await http.post(
    Uri.parse('$baseUrl/cases'),

    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({
      "description_case": descriptionCase,
      "client_id": clientId,
      "lawyer_id": lawyerId,
      "phone": phone,
      "address": address,
      "case_type": caseType,
      "name": name,
      "case_start_date": caseStartDate,
      "case_status": caseStatus,
      "depart_concern": departConcern,
      "hearing_date": hearingDate,
      "payment_status": paymentStatus,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception(response.body);
  }
}
  // GET all cases
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

  // DELETE a case
  static Future<void> deleteCase(int caseId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cases/$caseId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete case: ${response.statusCode}');
    }
  }

  // UPDATE case status
  static Future<void> updateCaseStatus(int caseId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/cases/$caseId/status/$newStatus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'case_status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.statusCode}');
    }
  }
}

// ─── Manage Cases Page ───────────────────────────────────────────────────────
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController caseTypeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController clientIdController = TextEditingController();
  final TextEditingController lawyerIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController departController = TextEditingController();
  final TextEditingController hearingDateController = TextEditingController();

  Future<void> _showAddCaseDialog() async {
    String selectedStatus = 'pending';
    String paymentStatus = 'unpaid';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Case'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Client Name',
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: caseTypeController,
                      decoration: const InputDecoration(labelText: 'Case Type'),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: clientIdController,
                      decoration: const InputDecoration(labelText: 'Client ID'),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: lawyerIdController,
                      decoration: const InputDecoration(labelText: 'Lawyer ID'),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: departController,
                      decoration: const InputDecoration(
                        labelText: 'Department Concern',
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: hearingDateController,
                      decoration: const InputDecoration(
                        labelText: 'Hearing Date (YYYY-MM-DD)',
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'hearing',
                          child: Text('Hearing'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Closed'),
                        ),
                      ],
                      onChanged: (v) {
                        setStateDialog(() {
                          selectedStatus = v!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Case Status',
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      items: const [
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem(
                          value: 'unpaid',
                          child: Text('Unpaid'),
                        ),
                      ],
                      onChanged: (v) {
                        setStateDialog(() {
                          paymentStatus = v!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Payment Status',
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    try {
                      // IMPORTANT:
                      // replace with your real token
                      String token = "YOUR_TOKEN_HERE";

                      await CaseApiService.createCase(
                        descriptionCase: descriptionController.text,
                        clientId: clientIdController.text,
                        lawyerId: lawyerIdController.text,
                        phone: phoneController.text,
                        address: addressController.text,
                        caseType: caseTypeController.text,
                        name: nameController.text,
                        caseStartDate: DateTime.now().toString().split(' ')[0],
                        caseStatus: selectedStatus,
                        departConcern: departController.text,
                        hearingDate: hearingDateController.text,
                        paymentStatus: paymentStatus,
                        token: token,
                      );

                      Navigator.pop(context);

                      _loadCases();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Case created successfully'),
                        ),
                      );

                      nameController.clear();
                      caseTypeController.clear();
                      descriptionController.clear();
                      clientIdController.clear();
                      lawyerIdController.clear();
                      phoneController.clear();
                      addressController.clear();
                      departController.clear();
                      hearingDateController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  // ── Fetch cases from backend ──────────────────────────────────────────────
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

  // ── Delete case with confirmation ─────────────────────────────────────────
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
        await CaseApiService.deleteCase(c.id);
        _loadCases(); // Refresh list
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

  // ── Update status ─────────────────────────────────────────────────────────
  Future<void> _updateStatus(CaseModel c, String newStatus) async {
    try {
      await CaseApiService.updateCaseStatus(c.id, newStatus);
      _loadCases();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ── Filtered list ─────────────────────────────────────────────────────────
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

  // ── Computed stats ────────────────────────────────────────────────────────
  int get approvedCases =>
    allCases.where((c) => c.caseStatus.toLowerCase() == 'approved').length;

int get closedCases =>
    allCases.where((c) => c.caseStatus.toLowerCase() == 'closed').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          ),
        ),
        title: const Text(
          'List of Cases',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddCaseDialog,
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
                'View and manage all cases with payment status',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by case ID, client, lawyer...',
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
              child: Row(
                children:
                    [
                      'All',
                      'Active',
                      'Approved',
                      'Pending',
                      'Closed',
                      'Rejected',
                      'Hearing',
                    ].map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => selectedFilter = filter),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF5D4037)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(filter),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            _buildTableHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Body: loading / error / list ──────────────────────────────────────────
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.brown),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadCases, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (filteredCases.isEmpty) {
      return const Center(child: Text('No cases found'));
    }
    return ListView.builder(
      itemCount: filteredCases.length,
      itemBuilder: (_, index) => _buildCaseRow(filteredCases[index]),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total Cases', 'value': '${allCases.length}'},
      {'label': 'Approved Cases', 'value': '$approvedCases'},
      {'label': 'Closed', 'value': '$closedCases'},
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Table Header ──────────────────────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Lawyer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Case Row ──────────────────────────────────────────────────────────────
  Widget _buildCaseRow(CaseModel c) {
    final isActive = c.caseStatus.toLowerCase() == 'active';
    final isCompleted = c.caseStatus.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('#${c.id}', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.caseType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  c.clientName,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(c.lawyerName, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.shade100
                    : isCompleted
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c.caseStatus,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? Colors.green.shade800
                      : isCompleted
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
                const PopupMenuItem(value: 'active', child: Text('Set Active')),
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
