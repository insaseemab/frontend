import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/cases_services.dart';

class ManageCases extends StatefulWidget {
  const ManageCases({super.key});

  @override
  State<ManageCases> createState() => _ManageCasesState();
}

class _ManageCasesState extends State<ManageCases> {
  List cases = [];
  List filteredCases = [];

  bool isLoading = true;
  bool hasError = false;

  String searchQuery = '';
  String selectedFilter = 'All';

  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFF6B4F3F);
  static const Color bgColor = Color(0xFFF5F0EC);

  final List<String> filters = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    loadCases();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= SAFE HELPERS =================

  String safeString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  String safeLower(dynamic value) {
    return safeString(value).toLowerCase();
  }

  // ================= DATA =================

  void _onSearchChanged() {
    searchQuery = safeLower(_searchController.text);
    _applyFilters();
  }

  Future<void> loadCases() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await CasesService.fetchCases();

      cases = data ?? [];
      _applyFilters();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredCases = cases.where((c) {
      final name = safeLower(c["name"]);
      final caseNo = safeLower(c["cases"]);
      final status = safeLower(c["status"]);

      final matchesSearch =
          name.contains(searchQuery) || caseNo.contains(searchQuery);

      final matchesFilter = selectedFilter == 'All' ||
          status == selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    setState(() {});
  }

  // ================= STATUS =================

  Color _statusColor(dynamic status) {
    final s = safeLower(status);

    switch (s) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load cases"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Case Management",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "View and manage all cases with payment status",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      // ===== STATS =====
                      Row(
                        children: [
                          _statCard(
                              cases.length.toString(), "Total Cases"),
                          _statCard(
                              _countByStatus("active"), "Active Cases"),
                          _statCard(
                              _countByStatus("completed"),
                              "Completed Cases"),
                          _statCard(
                              _countByStatus("pending"),
                              "Pending Payment"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ===== TABLE =====
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText:
                                            "Search by case ID, client, lawyer...",
                                        prefixIcon:
                                            const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _filterButton("All"),
                                  _filterButton("Active"),
                                  _filterButton("Completed"),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _tableHeader(),
                              const Divider(),

                              Expanded(
                                child: filteredCases.isEmpty
                                    ? const Center(
                                        child: Text("No cases found"),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredCases.length,
                                        itemBuilder: (context, index) {
                                          return _tableRow(
                                              filteredCases[index]);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  // ================= COMPONENTS =================

  Widget _statCard(String count, String title) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(count,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          selectedFilter = label;
          _applyFilters();
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return const Row(
      children: [
        Expanded(flex: 2, child: Text("Case ID")),
        Expanded(flex: 3, child: Text("Title")),
        Expanded(flex: 2, child: Text("Client")),
        Expanded(flex: 2, child: Text("Lawyer")),
        Expanded(flex: 2, child: Text("Status")),
        Expanded(flex: 2, child: Text("Payment")),
        Expanded(flex: 2, child: Text("Next Hearing")),
      ],
    );
  }

  Widget _tableRow(Map c) {
    final status = c["status"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(safeString(c["cases"]))),
          Expanded(flex: 3, child: Text(safeString(c["name"]))),
          Expanded(flex: 2, child: Text(safeString(c["client"]))),
          Expanded(flex: 2, child: Text(safeString(c["lawyer"]))),

          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                safeString(status),
                style: TextStyle(color: _statusColor(status)),
              ),
            ),
          ),

          Expanded(flex: 2, child: Text(safeString(c["payment"]))),
          Expanded(flex: 2, child: Text(safeString(c["date"]))),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  String _countByStatus(String status) {
    return cases
        .where((c) => safeLower(c["status"]) == status)
        .length
        .toString();
  }
}