import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
class ManageCases extends StatefulWidget {
  const ManageCases({super.key});

  @override
  State<ManageCases> createState() => _ManageCasesState();
}

class _ManageCasesState extends State<ManageCases> {
  List cases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('dtest');
    loadCases();
  }

  Future<void> loadCases() async {

    print('load cases');
    try {
      final data = await CasesService.fetchCases();
      print('test');
      setState(() {
        cases = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Cases")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cases.length,
              itemBuilder: (context, index) {
                final caseItem = cases[index];

                return ListTile(
                  title: Text(caseItem["name"] ?? ""),
                  subtitle: Text("Case No: ${caseItem["cases"] ?? ""}"),
                  trailing: Text(caseItem["status"] ?? ""),
                );
              },
            ),
    );
  }
}