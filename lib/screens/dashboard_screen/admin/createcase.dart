import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:get_storage/get_storage.dart';

class CreateCasePage extends StatefulWidget {
  const CreateCasePage({super.key});

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  final nameController = TextEditingController();
  final caseTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final clientIdController = TextEditingController();
  final lawyerIdController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final departController = TextEditingController();
  final hearingDateController = TextEditingController();

  String selectedStatus = 'pending';
  String paymentStatus = 'unpaid';

  bool isLoading = false;

  Future<void> createCase() async {
    try {
      setState(() {
        isLoading = true;
      });

      final box = GetStorage();

      String token = box.read('token');

      await CasesService.createCase(
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case Created Successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
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

            buildField('Client ID', clientIdController),

            buildField('Lawyer ID', lawyerIdController),

            buildField('Phone', phoneController),

            buildField('Address', addressController),

            buildField('Department Concern', departController),

            buildField('Hearing Date (YYYY-MM-DD)', hearingDateController),

            DropdownButtonFormField<String>(
              initialValue: selectedStatus,

              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),

                DropdownMenuItem(value: 'approved', child: Text('Approved')),

                DropdownMenuItem(value: 'hearing', child: Text('Hearing')),

                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],

              onChanged: (v) {
                setState(() {
                  selectedStatus = v!;
                });
              },

              decoration: const InputDecoration(labelText: 'Case Status'),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: paymentStatus,

              items: const [
                DropdownMenuItem(value: 'paid', child: Text('Paid')),

                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
              ],

              onChanged: (v) {
                setState(() {
                  paymentStatus = v!;
                });
              },

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
