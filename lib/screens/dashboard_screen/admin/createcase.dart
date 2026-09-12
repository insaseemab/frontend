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
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedCaseType;
  String selectedStatus = 'pending';
  int paymentStatus = 0; // 0=unpaid 1=paid
  String? selectedClientId;
  String? selectedLawyerId;
  String? selectedDepartment;
  DateTime? selectedHearingDate;

  bool isLoading = false;
  bool isFetchingData = true;
  bool isNewClient = false;
  bool _obscurePassword = true;

  String userRole = 'client';
  List<Map<String, String>> clients = [];
  List<Map<String, String>> lawyers = [];

  final List<String> caseTypes = [
    'Consultation',
    'Representation',
    'Document Review',
    'Contract Drafting',
    'Litigation',
    'Arbitration',
    'Mediation',
    'Legal Advisory',
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

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    userRole = (box.read('role') ?? 'lawyer').toString().toLowerCase();
    final currentUserId = box.read('userId')?.toString();
    if (userRole == 'lawyer') {
      selectedLawyerId = currentUserId;
    }
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final futures = <Future>[
        CasesService.fetchClients(),
      ];
      if (userRole == 'admin') {
        futures.add(CasesService.fetchLawyers());
      }

      final results = await Future.wait(futures);

      setState(() {
        clients = (results[0] as List)
            .map<Map<String, String>>(
              (c) => {
                'id': c['id'].toString(),
                'name': c['name']?.toString() ?? 'Unknown',
                'email': c['email']?.toString() ?? '',
                'location': c['location']?.toString() ?? '',
                'phone': c['phone']?.toString() ?? '',
              },
            )
            .toList();

        if (userRole == 'admin' && results.length > 1) {
          lawyers = (results[1] as List)
              .map<Map<String, String>>(
                (l) => {
                  'id': l['id'].toString(),
                  'name': l['name']?.toString() ?? 'Unknown',
                  'specialization': l['specialization']?.toString() ?? '',
                },
              )
              .toList();
        }

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
      initialDate: DateTime.now().add(const Duration(days: 1)),
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> createCase() async {
    // 1. Client validation
    if (isNewClient) {
      if (nameController.text.trim().isEmpty) {
        _showError('Please enter client name');
        return;
      }
      final email = emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _showError('Please enter a valid client email');
        return;
      }
      if (passwordController.text.trim().length < 6) {
        _showError('Client temporary password must be at least 6 characters');
        return;
      }
    } else {
      if (selectedClientId == null) {
        _showError('Please select a client from the dropdown');
        return;
      }
    }

    // 2. Client contact details
    if (phoneController.text.trim().isEmpty) {
      _showError('Please enter client phone number');
      return;
    }
    if (addressController.text.trim().isEmpty) {
      _showError('Please enter client address');
      return;
    }

    // 3. Lawyer assignment validation
    final box = GetStorage();
    final effectiveLawyerId = selectedLawyerId ??
        (userRole == 'lawyer' ? box.read('userId')?.toString() : null);

    if (effectiveLawyerId == null || effectiveLawyerId.isEmpty) {
      _showError(userRole == 'admin'
          ? 'Please assign a lawyer to this case'
          : 'Could not identify logged-in lawyer. Please log in again.');
      return;
    }

    // 4. Case details validation
    if (selectedCaseType == null || selectedCaseType!.isEmpty) {
      _showError('Please select a case type');
      return;
    }
    if (selectedDepartment == null || selectedDepartment!.isEmpty) {
      _showError('Please select a department');
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showError('Please enter case description');
      return;
    }
    if (selectedHearingDate == null) {
      _showError('Please select a hearing date');
      return;
    }

    try {
      setState(() => isLoading = true);

      final String token = box.read('token') ?? '';
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
        lawyerId: effectiveLawyerId,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        caseType: selectedCaseType!,
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
        const SnackBar(
          content: Text('Case Created Successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Get.back(result: true);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
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

  InputDecoration _inputDecor(String hint, {Widget? suffixIcon}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: _hintColor),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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
      );

  // ── Themed text field: label above + filled box below ──
  Widget _themedField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String hint = '',
    bool obscureText = false,
    Widget? suffixIcon,
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
            obscureText: obscureText,
            decoration: _inputDecor(
              hint.isEmpty ? 'Enter $label' : hint,
              suffixIcon: suffixIcon,
            ),
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
    String Function(Map<String, String>)? titleBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint, style: TextStyle(fontSize: 13, color: _hintColor)),
            decoration: _inputDecor(hint),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e['id'],
                    child: Text(
                      titleBuilder != null
                          ? titleBuilder(e)
                          : '${e['name']} (${e['id']})',
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
            value: value,
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
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Client Information ──
                    _sectionLabel('Client Information'),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Existing Client'),
                          selected: !isNewClient,
                          selectedColor: _primaryColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: !isNewClient ? _primaryColor : Colors.black87,
                            fontWeight: !isNewClient
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            setState(() {
                              isNewClient = false;
                              selectedClientId = null;
                              nameController.clear();
                              phoneController.clear();
                              addressController.clear();
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
                            fontWeight: isNewClient
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            setState(() {
                              isNewClient = true;
                              selectedClientId = null;
                              nameController.clear();
                              phoneController.clear();
                              addressController.clear();
                              emailController.clear();
                              passwordController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!isNewClient)
                      _themedIdDropdown(
                        label: 'Select Client *',
                        hint: 'Choose existing client',
                        value: selectedClientId,
                        items: clients,
                        titleBuilder: (c) => c['email'] != null &&
                                c['email']!.isNotEmpty
                            ? '${c['name']} (${c['email']})'
                            : '${c['name']} (ID: ${c['id']})',
                        onChanged: (v) {
                          setState(() {
                            selectedClientId = v;
                            final selected =
                                clients.firstWhereOrNull((c) => c['id'] == v);
                            if (selected != null) {
                              nameController.text = selected['name'] ?? '';
                              if ((selected['location'] ?? '').isNotEmpty) {
                                addressController.text = selected['location']!;
                              }
                              if ((selected['phone'] ?? '').isNotEmpty) {
                                phoneController.text = selected['phone']!;
                              }
                            }
                          });
                        },
                      )
                    else ...[
                      _themedField('Client Name *', nameController,
                          hint: 'Enter client full name'),
                      _themedField(
                        'Client Email *',
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'client@example.com',
                      ),
                      _themedField(
                        'Temporary Password *',
                        passwordController,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        hint: 'Minimum 6 characters',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: _hintColor,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ],

                    _themedField(
                      'Client Phone *',
                      phoneController,
                      keyboardType: TextInputType.phone,
                      hint: '03001234567',
                    ),
                    _themedField(
                      'Client Address *',
                      addressController,
                      hint: 'City, area or full address',
                    ),

                    const SizedBox(height: 10),

                    // ── 2. Lawyer Assignment (if Admin) ──
                    if (userRole == 'admin') ...[
                      _sectionLabel('Lawyer Assignment'),
                      _themedIdDropdown(
                        label: 'Assign Lawyer *',
                        hint: 'Select lawyer for this case',
                        value: selectedLawyerId,
                        items: lawyers,
                        titleBuilder: (l) =>
                            '${l['name']}${l['specialization'] != null && l['specialization']!.isNotEmpty ? ' (${l['specialization']})' : ''}',
                        onChanged: (v) => setState(() => selectedLawyerId = v),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── 3. Case Details ──
                    _sectionLabel('Case Details'),

                    // Standardized Case Type Dropdown for both flows
                    _themedDropdown(
                      label: 'Case Type *',
                      hint: 'Select case type',
                      value: selectedCaseType,
                      items: caseTypes,
                      onChanged: (v) => setState(() => selectedCaseType = v),
                    ),

                    _themedDropdown(
                      label: 'Department Concern *',
                      hint: 'Select department',
                      value: selectedDepartment,
                      items: departments,
                      onChanged: (v) => setState(() => selectedDepartment = v),
                    ),

                    // Hearing Date Picker
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Hearing Date *'),
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
                                        ? 'Tap to select hearing date'
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

                    _themedField(
                      'Case Description *',
                      descriptionController,
                      maxLines: 3,
                      hint: 'Briefly describe the legal matter or case details...',
                    ),

                    const SizedBox(height: 10),

                    // ── 4. Status & Payment ──
                    _sectionLabel('Status & Payment'),

                    _themedDropdown(
                      label: 'Case Status',
                      hint: 'Select status',
                      value: selectedStatus,
                      items: const ['pending', 'approved', 'hearing', 'closed'],
                      onChanged: (v) => setState(() => selectedStatus = v!),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Payment Status'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: paymentStatus,
                            isExpanded: true,
                            decoration: _inputDecor('Select payment status'),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Unpaid')),
                              DropdownMenuItem(value: 1, child: Text('Paid')),
                            ],
                            onChanged: (v) =>
                                setState(() => paymentStatus = v ?? 0),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Submit Button ──
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
                          disabledBackgroundColor:
                              _primaryColor.withOpacity(0.5),
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
            ),
    );
  }
}