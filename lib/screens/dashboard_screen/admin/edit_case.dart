import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/manage_cases.dart';
import 'package:get/get.dart';

class EditCaseDialog extends StatefulWidget {
  final CaseModel caseData;

  const EditCaseDialog({super.key, required this.caseData});

  @override
  State<EditCaseDialog> createState() => _EditCaseDialogState();
}

class _EditCaseDialogState extends State<EditCaseDialog> {
  late TextEditingController nameController;
  late TextEditingController caseTypeController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  late TextEditingController departController;
  late TextEditingController hearingDateController;

  late String selectedPaymentStatus;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.caseData.clientName);
    caseTypeController = TextEditingController(text: widget.caseData.caseType);
    phoneController = TextEditingController();
    addressController = TextEditingController();
    descriptionController = TextEditingController();
    departController = TextEditingController();
    hearingDateController =
        TextEditingController(text: widget.caseData.hearingDate);
    selectedPaymentStatus = widget.caseData.paymentStatus.toLowerCase() == 'paid'
        ? 'paid'
        : 'unpaid';
  }

  @override
  void dispose() {
    nameController.dispose();
    caseTypeController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    departController.dispose();
    hearingDateController.dispose();
    super.dispose();
  }

  Future<void> _updateCase() async {
    try {
      setState(() => loading = true);

      final String token = GetStorage().read('token') ?? '';

      await CaseApiService.updateCase(
        id: widget.caseData.id,
        name: nameController.text.trim(),
        caseType: caseTypeController.text.trim(),
        caseStatus: widget.caseData.caseStatus,
        descriptionCase: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        caseStartDate: '',
        departConcern: departController.text.trim(),
        hearingDate: hearingDateController.text.trim(),
        paymentStatus: selectedPaymentStatus,
        token: token,
      );

      if (!mounted) return;

      Get.back(result: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Case',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Client Name', nameController),
            _buildField('Case Type', caseTypeController),
            _buildField('Description', descriptionController),
            _buildField('Phone', phoneController,
                keyboardType: TextInputType.phone),
            _buildField('Address', addressController),
            _buildField('Department Concern', departController),
            _buildField('Hearing Date (YYYY-MM-DD)', hearingDateController),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPaymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: UnderlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => selectedPaymentStatus = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: loading ? null : _updateCase,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
          ),
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}