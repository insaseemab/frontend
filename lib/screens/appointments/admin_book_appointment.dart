import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/core/services/api_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:get/get.dart';

final Color _primaryColor = AppColors.darkBrown;
final Color _bgColor = AppColors.beige;
final Color _borderColor = AppColors.divider;
final Color _hintColor = AppColors.hintText;
final Color _labelColor = AppColors.labelSecondary;

class AdminBookAppointmentScreen extends StatefulWidget {
  final DateTime? initialDate;
  const AdminBookAppointmentScreen({super.key, this.initialDate});

  @override
  State<AdminBookAppointmentScreen> createState() => _AdminBookAppointmentScreenState();
}

class _AdminBookAppointmentScreenState extends State<AdminBookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();

  String? _selectedClientId;
  String? _selectedLawyerId;
  String? _selectedLawType;
  String? _selectedCaseType;
  String _appointmentMode = 'online';

  DateTime? _slotStart;
  DateTime? _slotEnd;

  bool _isLoading = false;
  bool _isFetchingData = true;

  List<Map<String, String>> _clients = [];
  List<Map<String, String>> _lawyers = [];

  final List<String> _lawTypes = [
    'Civil Law',
    'Criminal Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
    'Labour Law',
    'Tax Law',
  ];

  final List<String> _caseTypes = [
    'Consultation',
    'Representation',
    'Document Review',
    'Contract Drafting',
    'Litigation',
    'Arbitration',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
    if (widget.initialDate != null) {
      _slotStart = widget.initialDate;
      _slotEnd = widget.initialDate!.add(const Duration(hours: 1));
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final results = await Future.wait([
        CasesService.fetchLawyers(),
        CasesService.fetchClients(),
      ]);

      setState(() {
        _lawyers = results[0]
            .map<Map<String, String>>(
              (l) => {
                'id': l['id'].toString(),
                'name': l['name']?.toString() ?? 'Unknown',
              },
            )
            .toList();

        _clients = results[1]
            .map<Map<String, String>>(
              (c) => {
                'id': c['id'].toString(),
                'name': c['name']?.toString() ?? 'Unknown',
              },
            )
            .toList();

        _isFetchingData = false;
      });
    } catch (e) {
      setState(() => _isFetchingData = false);
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

  String _fmtDateTime(DateTime dt) =>
      dt.toIso8601String().replaceFirst('T', ' ').substring(0, 19);

  Future<void> _pickSlot({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _slotStart = combined;
        _slotEnd = null;
      } else {
        _slotEnd = combined;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClientId == null) {
      _showSnack('Please select a client.');
      return;
    }
    if (_selectedLawyerId == null) {
      _showSnack('Please select a lawyer.');
      return;
    }
    if (_slotStart == null || _slotEnd == null) {
      _showSnack('Please select both slot start and end times.');
      return;
    }
    if (_slotEnd!.isBefore(_slotStart!) ||
        _slotEnd!.isAtSameMomentAs(_slotStart!)) {
      _showSnack('Slot end time must be after slot start time.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppointmentService.createAppointment(
        clientId: int.parse(_selectedClientId!),
        lawyerId: int.parse(_selectedLawyerId!),
        lawType: _selectedLawType!,
        caseType: _selectedCaseType!,
        shortDescription: _descriptionCtrl.text.trim(),
        slotStartTime: _fmtDateTime(_slotStart!),
        slotEndTime: _fmtDateTime(_slotEnd!),
        appointmentMode: _appointmentMode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!'),
         backgroundColor: Color(0xFF2E7D32),
         ),
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _primaryColor,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Book Appointment (Admin)',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isFetchingData
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Select Parties'),
                    const SizedBox(height: 10),

                    _DropdownField(
                      label: 'Client / Customer',
                      hint: 'Select client',
                      value: _selectedClientId,
                      items: _clients,
                      onChanged: (v) => setState(() => _selectedClientId = v),
                      validator: (v) => v == null ? 'Please select a client' : null,
                    ),
                    const SizedBox(height: 12),

                    _DropdownField(
                      label: 'Lawyer',
                      hint: 'Select lawyer',
                      value: _selectedLawyerId,
                      items: _lawyers,
                      onChanged: (v) => setState(() => _selectedLawyerId = v),
                      validator: (v) => v == null ? 'Please select a lawyer' : null,
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Case Details'),
                    const SizedBox(height: 10),

                    _AppDropdown(
                      label: 'Law Type',
                      hint: 'Select law type',
                      value: _selectedLawType,
                      items: _lawTypes,
                      onChanged: (v) => setState(() => _selectedLawType = v),
                      validator: (v) => v == null ? 'Please select a law type' : null,
                    ),
                    const SizedBox(height: 12),

                    _AppDropdown(
                      label: 'Case Type',
                      hint: 'Select case type',
                      value: _selectedCaseType,
                      items: _caseTypes,
                      onChanged: (v) => setState(() => _selectedCaseType = v),
                      validator: (v) => v == null ? 'Please select a case type' : null,
                    ),
                    const SizedBox(height: 12),

                    _fieldLabel('Short Description'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: _inputDecor('Briefly describe the legal matter...'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Time Slot'),
                    const SizedBox(height: 10),
                    _SlotPicker(
                      label: 'Start Time',
                      dateTime: _slotStart,
                      onTap: () => _pickSlot(isStart: true),
                    ),
                    const SizedBox(height: 12),
                    _SlotPicker(
                      label: 'End Time',
                      dateTime: _slotEnd,
                      onTap: () => _pickSlot(isStart: false),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('Appointment Mode'),
                    const SizedBox(height: 10),
                    _ModeSelector(
                      options: const ['online', 'physical'],
                      selected: _appointmentMode,
                      icons: const [Icons.videocam_outlined, Icons.person_outline],
                      onSelected: (v) => setState(() => _appointmentMode = v),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          disabledBackgroundColor:
                              _primaryColor.withValues(alpha: 0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Book Appointment',
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
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 13, color: _hintColor),
          ),
          decoration: InputDecoration(
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
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e['id'], child: Text(e['name'] ?? '')))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

class _AppDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const _AppDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 13, color: _hintColor),
          ),
          decoration: InputDecoration(
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
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

class _SlotPicker extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final VoidCallback onTap;

  const _SlotPicker({
    required this.label,
    required this.dateTime,
    required this.onTap,
  });

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final display = dateTime != null
        ? '${dateTime!.year}-${_pad(dateTime!.month)}-${_pad(dateTime!.day)}  ${_pad(dateTime!.hour)}:${_pad(dateTime!.minute)}'
        : 'Tap to select';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: _primaryColor,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: _labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: dateTime != null
                        ? _primaryColor
                        : _hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final List<IconData> icons;
  final ValueChanged<String> onSelected;

  const _ModeSelector({
    required this.options,
    required this.selected,
    required this.icons,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final isActive = options[i] == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(options[i]),
            child: Container(
              margin: EdgeInsets.only(right: i < options.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? _primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? _primaryColor : _borderColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[i],
                    size: 16,
                    color: isActive ? Colors.white : _labelColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    options[i][0].toUpperCase() + options[i].substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : _labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
