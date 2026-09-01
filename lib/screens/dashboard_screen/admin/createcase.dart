import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/core/services/auth_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

final Color _primaryColor = AppColors.Brown;
final Color _bgColor = AppColors.beige;
final Color _borderColor = AppColors.divider;
final Color _hintColor = AppColors.hintText;

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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedStatus = 'pending';
  int paymentStatus = 0; // int, 0=unpaid 1=paid
  String? selectedClientId;
  String? selectedDepartment;
  DateTime? selectedHearingDate;

  bool isLoading = false;
  bool isFetchingData = true;
  bool isNewClient = false;

  List<Map<String, String>> clients = [];

  // The logged-in lawyer's own ID — pulled from storage, not picked from a dropdown.
  String? currentLawyerId;

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
    final box = GetStorage();
    currentLawyerId = box.read('userId')?.toString();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final results = await Future.wait([
        CasesService.fetchClients(),
      ]);

      setState(() {
        clients = results[0]
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
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
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
        (isNewClient
            ? emailController.text.trim().isEmpty
            : selectedClientId == null) ||
        selectedDepartment == null ||
        selectedHearingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (currentLawyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not identify the logged-in lawyer. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final box = GetStorage();
      final String token = box.read('token');

      String? finalClientId = selectedClientId;

      if (isNewClient) {
        final regRes = await AuthService.register({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'role': 'client',
        });

        if (regRes['success'] == true) {
          finalClientId = regRes['userId']?.toString();
        } else {
          throw Exception(regRes['message'] ?? 'Failed to register new client');
        }
      }

      if (finalClientId == null) {
        throw Exception('Client ID is missing');
      }

      await CasesService.createCase(
        descriptionCase: descriptionController.text.trim(),
        clientId: finalClientId,
        lawyerId: currentLawyerId!,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        caseType: caseTypeController.text.trim(),
        name: nameController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    caseTypeController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: _hintColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  // ── Themed text field: label above + filled box below ──
  Widget _themedField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String hint = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: _inputDecor(hint.isEmpty ? 'Enter $label' : hint),
          ),
        ],
      ),
    );
  }

  // ── Themed dropdown (string ids with display names) ──
  Widget _themedIdDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            hint: Text(hint, style: TextStyle(fontSize: 13, color: _hintColor)),
            decoration: _inputDecor(hint),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e['id'],
                    child: Text(
                      '${e['name']} (${e['id']})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ── Themed dropdown (plain string values) ──
  Widget _themedDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            hint: Text(hint, style: TextStyle(fontSize: 13, color: _hintColor)),
            decoration: _inputDecor(hint),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Case',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isFetchingData
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Client'),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Existing Client'),
                        selected: !isNewClient,
                        selectedColor: _primaryColor.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: !isNewClient ? _primaryColor : Colors.black87,
                          fontWeight:
                              !isNewClient ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          setState(() {
                            isNewClient = false;
                            selectedClientId = null;
                            nameController.clear();
                            phoneController.clear();
                            emailController.clear();
                            passwordController.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('New Client'),
                        selected: isNewClient,
                        selectedColor: _primaryColor.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isNewClient ? _primaryColor : Colors.black87,
                          fontWeight:
                              isNewClient ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          setState(() {
                            isNewClient = true;
                            selectedClientId = null;
                            nameController.clear();
                            phoneController.clear();
                            emailController.clear();
                            passwordController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _themedField('Client Name', nameController),
                  if (isNewClient) ...[
                    _themedField('Client Email', emailController,
                        keyboardType: TextInputType.emailAddress),
                    _themedField('Temporary Password', passwordController,
                        keyboardType: TextInputType.visiblePassword),
                  ],

                  if (!isNewClient)
                    _themedIdDropdown(
                      label: 'Client',
                      hint: 'Select client',
                      value: selectedClientId,
                      items: clients,
                      onChanged: (v) {
                        setState(() {
                          selectedClientId = v;
                          final selected =
                              clients.firstWhereOrNull((c) => c['id'] == v);
                          if (selected != null) {
                            nameController.text = selected['name'] ?? '';
                          }
                        });
                      },
                    ),

                  const SizedBox(height: 8),
                  _sectionLabel('Case Details'),
                  const SizedBox(height: 10),

                  _themedField('Case Type', caseTypeController,
                      hint: 'Enter case type'),
                  _themedField(
                    'Description',
                    descriptionController,
                    maxLines: 3,
                    hint: 'Briefly describe the legal matter...',
                  ),

                  _themedField('Phone', phoneController,
                      keyboardType: TextInputType.phone,
                      hint: 'Enter phone number'),
                  _themedField('Address', addressController,
                      hint: 'Enter address'),

                  _themedDropdown(
                    label: 'Department Concern',
                    hint: 'Select department',
                    value: selectedDepartment,
                    items: departments,
                    onChanged: (v) => setState(() => selectedDepartment = v),
                  ),

                  // ── Hearing Date ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Hearing Date'),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: pickHearingDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 18, color: _primaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  selectedHearingDate == null
                                      ? 'Tap to select'
                                      : selectedHearingDate!
                                          .toString()
                                          .split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selectedHearingDate != null
                                        ? _primaryColor
                                        : _hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  _sectionLabel('Status'),
                  const SizedBox(height: 10),

                  _themedDropdown(
                    label: 'Case Status',
                    hint: 'Select status',
                    value: selectedStatus,
                    items: const ['pending', 'approved', 'hearing', 'closed'],
                    onChanged: (v) => setState(() => selectedStatus = v!),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Payment Status'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: paymentStatus,
                          isExpanded: true,
                          decoration: _inputDecor('Select payment status'),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Unpaid')),
                            DropdownMenuItem(value: 1, child: Text('Paid')),
                          ],
                          onChanged: (v) => setState(() => paymentStatus = v!),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : createCase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Create Case',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}