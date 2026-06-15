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
  String paymentStatus = 'unpaid';
  String? selectedClientId;
  String? selectedLawyerId;
  String? selectedDepartment;
  DateTime? selectedHearingDate;

  bool isLoading = false;

  // ── Dummy data (replace with API later) ──────────────────────
  final List<Map<String, String>> clients = [
    {'id': 'C001', 'name': 'Ahmed Khan'},
    {'id': 'C002', 'name': 'Sara Ali'},
    {'id': 'C003', 'name': 'Usman Raza'},
    {'id': 'C004', 'name': 'Fatima Malik'},
  ];

  final List<Map<String, String>> lawyers = [
    {'id': 'L001', 'name': 'Barrister Asad'},
    {'id': 'L002', 'name': 'Advocate Nadia'},
    {'id': 'L003', 'name': 'Barrister Tariq'},
    {'id': 'L004', 'name': 'Advocate Hina'},
  ];

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
    if (selectedClientId == null ||
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
      String token = box.read('token');

      await CasesService.createCase(
        descriptionCase: descriptionController.text,
        clientId: selectedClientId!,
        lawyerId: selectedLawyerId!,
        phone: phoneController.text,
        address: addressController.text,
        caseType: caseTypeController.text,
        name: nameController.text,
        caseStartDate: DateTime.now().toString().split(' ')[0],
        caseStatus: selectedStatus,
        departConcern: selectedDepartment!,
        hearingDate: selectedHearingDate!.toString().split(' ')[0],
        paymentStatus: paymentStatus,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case Created Successfully')),
      );

      Get.back(result: true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Case'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField('Client Name', nameController),
            buildField('Case Type', caseTypeController),
            buildField('Description', descriptionController),

            // ── Client Select ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: selectedClientId,
                hint: const Text('Select Client'),
                items: clients
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text('${c['name']} (${c['id']})'),
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
                value: selectedLawyerId,
                hint: const Text('Select Lawyer'),
                items: lawyers
                    .map(
                      (l) => DropdownMenuItem(
                        value: l['id'],
                        child: Text('${l['name']} (${l['id']})'),
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

            buildField('Phone', phoneController),
            buildField('Address', addressController),

            // ── Department Concern Select ──────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: selectedDepartment,
                hint: const Text('Select Department'),
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => selectedDepartment = v),
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
                          : selectedHearingDate!.toString().split(' ')[0],
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
                          : selectedHearingDate!.toString().split(' ')[0],
                    ),
                  ),
                ),
              ),
            ),

            // ── Case Status ────────────────────────────────────
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'hearing', child: Text('Hearing')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (v) => setState(() => selectedStatus = v!),
              decoration: const InputDecoration(labelText: 'Case Status'),
            ),

            const SizedBox(height: 16),

            // ── Payment Status ─────────────────────────────────
            DropdownButtonFormField<String>(
              value: paymentStatus,
              items: const [
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
              ],
              onChanged: (v) => setState(() => paymentStatus = v!),
              decoration: const InputDecoration(labelText: 'Payment Status'),
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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Case'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
