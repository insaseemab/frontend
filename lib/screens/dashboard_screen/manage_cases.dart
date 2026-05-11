import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ─── Root App ───────────────────────────────────────────────────────────────
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

// ─── Data Model ─────────────────────────────────────────────────────────────
class CaseModel {
  final String caseId;
  final String title;
  final String client;
  final String lawyer;
  final String status;
  final int payment;
  final String nextHearing;

  CaseModel({
    required this.caseId,
    required this.title,
    required this.client,
    required this.lawyer,
    required this.status,
    required this.payment,
    required this.nextHearing,
  });
}

// ─── Manage Cases Page ───────────────────────────────────────────────────────
class ManageCasesPage extends StatefulWidget {
  const ManageCasesPage({super.key});

  @override
  State<ManageCasesPage> createState() => _ManageCasesPageState();
}

class _ManageCasesPageState extends State<ManageCasesPage> {
  // Sample data
  final List<CaseModel> allCases = [
    CaseModel(
      caseId: '250 cases',
      title: 'Property Dispute',
      client: 'Ali Raza',
      lawyer: 'Adv. Ahmad Khan',
      status: 'Active',
      payment: 0,
      nextHearing: '2026-05-15',
    ),
    CaseModel(
      caseId: '180 cases',
      title: 'Family Matter',
      client: 'Fatima Noor',
      lawyer: 'Adv. Sarah Khan',
      status: 'Completed',
      payment: 1,
      nextHearing: 'N/A',
    ),
    CaseModel(
      caseId: '200 cases',
      title: 'Criminal Defense',
      client: 'Usman Tariq',
      lawyer: 'Adv. Bilal Ahmad',
      status: 'Active',
      payment: 0,
      nextHearing: '2026-06-01',
    ),
  ];

  String selectedFilter = 'All'; // 'All', 'Active', 'Completed'
  String searchQuery = '';

  // Filter cases based on search + filter button
  List<CaseModel> get filteredCases {
    return allCases.where((c) {
      final matchesFilter =
          selectedFilter == 'All' || c.status == selectedFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          c.caseId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.client.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.lawyer.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ), // Brown color
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
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {}, // Notification button
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Container(
        color: const Color(0xFFF5F0EB), // Light beige background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page Title ────────────────────────────────────────────────
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

            // ── Stats Row ─────────────────────────────────────────────────
            _buildStatsRow(),

            const SizedBox(height: 16),

            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
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

            // ── Filter Buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Active', 'Completed'].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => setState(() => selectedFilter = filter),
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

            // ── Table Header ──────────────────────────────────────────────
            _buildTableHeader(),

            // ── Cases List ────────────────────────────────────────────────
            Expanded(
              child: filteredCases.isEmpty
                  ? const Center(child: Text('No cases found'))
                  : ListView.builder(
                      itemCount: filteredCases.length,
                      itemBuilder: (context, index) {
                        return _buildCaseRow(filteredCases[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Cards Row Widget ───────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total Cases', 'value': '${allCases.length}'},
      {'label': 'Active Cases', 'value': '2'},
      {'label': 'Completed', 'value': '1'},
      {'label': 'Pending Payment', 'value': '0'},
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

  // ── Table Header Widget ──────────────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Case ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Title',
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
              'Pay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single Case Row Widget ───────────────────────────────────────────────
  Widget _buildCaseRow(CaseModel c) {
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
            flex: 2,
            child: Text(c.caseId, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(c.title, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(c.lawyer, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c.status == 'Active'
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c.status,
                style: TextStyle(
                  fontSize: 11,
                  color: c.status == 'Active' ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${c.payment}', style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
