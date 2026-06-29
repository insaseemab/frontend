import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class CreateCasePage extends StatefulWidget {
  const CreateCasePage({super.key});

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  final nameController = TextEditingController();
  final caseTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String selectedStatus = 'pending';
  int paymentStatus = 0; // ← int, 0=unpaid 1=paid
  String? selectedClientId;
  String? selectedLawyerId;
  String? selectedDepartment;
  DateTime? selectedHearingDate;

  bool isLoading = false;
  bool isFetchingData = true;

  List<Map<String, String>> clients = [];
  List<Map<String, String>> lawyers = [];

  final List<String> departments = [
    'Civil',
    'Criminal',
    'Family',
    'Corporate',
    'Property',
    'Labour',
    'Tax',
    'Constitutional',
  ];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final results = await Future.wait([
        CasesService.fetchLawyers(),
        CasesService.fetchClients(),
      ]);

      setState(() {
        lawyers = results[0]
            .map<Map<String, String>>(
              (l) => {
                'id': l['id'].toString(),
                'name': l['name']?.toString() ?? 'Unknown',
              },
            )
            .toList();

        clients = results[1]
            .map<Map<String, String>>(
              (c) => {
                'id': c['id'].toString(),
                'name': c['name']?.toString() ?? 'Unknown',
              },
            )
            .toList();

        isFetchingData = false;
      });
    } catch (e) {
      setState(() => isFetchingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> pickHearingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.brown,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedHearingDate = picked);
    }
  }

  Future<void> createCase() async {
    if (nameController.text.trim().isEmpty ||
        caseTypeController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        selectedClientId == null ||
        selectedLawyerId == null ||
        selectedDepartment == null ||
        selectedHearingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final box = GetStorage();
      final String token = box.read('token');

      await CasesService.createCase(
        descriptionCase: descriptionController.text.trim(),
        clientId: selectedClientId!,
        lawyerId: selectedLawyerId!,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        caseType: caseTypeController.text.trim(),
        name: nameController.text.trim(),
        caseStartDate: DateTime.now().toString().split(' ')[0],
        caseStatus: selectedStatus,
        departConcern: selectedDepartment!,
        hearingDate: selectedHearingDate!.toString().split(' ')[0],
        paymentStatus: paymentStatus, // ← int directly
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case Created Successfully')),
      );

      Get.back(result: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    caseTypeController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Case'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: isFetchingData
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildField('Client Name', nameController),
                  buildField('Case Type', caseTypeController),
                  buildField(
                    'Description',
                    descriptionController,
                    maxLines: 3,
                  ),

                  // ── Client Select ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedClientId, // ← fixed deprecation
                      hint: const Text('Select Client'),
                      isExpanded: true,
                      items: clients
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(
                                '${c['name']} (${c['id']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedClientId = v),
                      decoration: InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // ── Lawyer Select ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLawyerId, // ← fixed deprecation
                      hint: const Text('Select Lawyer'),
                      isExpanded: true,
                      items: lawyers
                          .map(
                            (l) => DropdownMenuItem(
                              value: l['id'],
                              child: Text(
                                '${l['name']} (${l['id']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedLawyerId = v),
                      decoration: InputDecoration(
                        labelText: 'Lawyer',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  buildField(
                    'Phone',
                    phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  buildField('Address', addressController),

                  // ── Department Concern Select ──────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedDepartment, // ← fixed deprecation
                      hint: const Text('Select Department'),
                      items: departments
                          .map(
                            (d) =>
                                DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedDepartment = v),
                      decoration: InputDecoration(
                        labelText: 'Department Concern',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // ── Hearing Date Picker ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: pickHearingDate,
                      child: AbsorbPointer(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Hearing Date',
                            hintText: selectedHearingDate == null
                                ? 'Select a date'
                                : selectedHearingDate!
                                    .toString()
                                    .split(' ')[0],
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.brown,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          controller: TextEditingController(
                            text: selectedHearingDate == null
                                ? ''
                                : selectedHearingDate!
                                    .toString()
                                    .split(' ')[0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Case Status ────────────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus, // ← fixed deprecation
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
                    onChanged: (v) => setState(() => selectedStatus = v!),
                    decoration:
                        const InputDecoration(labelText: 'Case Status'),
                  ),

                  const SizedBox(height: 16),

                  // ── Payment Status ─────────────────────────────────
                  DropdownButtonFormField<int>(
                    initialValue: paymentStatus, // ← fixed deprecation
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Unpaid')),
                      DropdownMenuItem(value: 1, child: Text('Paid')),
                    ],
                    onChanged: (v) => setState(() => paymentStatus = v!),
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : createCase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Create Case'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}