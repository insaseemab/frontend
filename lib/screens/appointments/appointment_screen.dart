import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/core/services/api_services.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/utils/theme.dart'; 


class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> lawyer;
  final DateTime? initialDate;

  const BookAppointmentScreen({super.key, required this.lawyer, this.initialDate});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionCtrl = TextEditingController();

  String? _selectedLawType;
  String? _selectedCaseType;
  String _appointmentMode = 'online';

  DateTime? _slotStart;
  DateTime? _slotEnd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _slotStart = widget.initialDate;
      _slotEnd = widget.initialDate!.add(const Duration(hours: 1));
    }
  }

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
            primary: AppColors.Brown,
            onPrimary: AppColors.white,
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
          colorScheme: ColorScheme.light(primary: AppColors.Brown),
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
        lawyerId: widget.lawyer['id'] as int,
        lawType: _selectedLawType!,
        caseType: _selectedCaseType!,
        shortDescription: _descriptionCtrl.text.trim(),
        slotStartTime: _fmtDateTime(_slotStart!),
        slotEndTime: _fmtDateTime(_slotEnd!),
        appointmentMode: _appointmentMode,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Network error. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 10),
            const Text('Appointment Sent!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your appointment with ${widget.lawyer['name']} has been submitted and is pending confirmation.',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  _StepText('1. Lawyer reviews your request'),
                  _StepText('2. You get notified of acceptance'),
                  _StepText('3. Lawyer shares payment details'),
                  _StepText('4. You complete the payment'),
                  _StepText('5. Appointment gets confirmed'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: Text('OK', style: TextStyle(color: AppColors.Brown)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.Brown,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Book Appointment',
          style: AppTextStyles.heading3,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LawyerSummaryCard(lawyer: widget.lawyer),
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
                validator: (v) =>
                    v == null ? 'Please select a case type' : null,
              ),
              const SizedBox(height: 12),

              _fieldLabel('Short Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: _inputDecor(
                  'Briefly describe your legal matter...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
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
              const SizedBox(height: 20),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Brown,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.Brown.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
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
    style: AppTextStyles.heading4.copyWith(fontSize: 16),
  );

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.mediumBrown,
    ),
  );

  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.hint,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.Brown, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}



class MyAppointmentsScreen extends StatefulWidget {
  final bool isStandalone;

  const MyAppointmentsScreen({super.key, this.isStandalone = false});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = AppointmentService.getMyAppointments(); // ← uses token automatically
    });
  }

  Future<void> _delete(int id) async {
    try {
      await AppointmentService.deleteAppointment(id);
      if (!mounted) return;
      _load();
      Get.snackbar(
        'Success',
        'Appointment cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildBody() {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.Brown),
          );
        }
        if (snap.hasError) {
          final msg = snap.error is ApiException
              ? (snap.error as ApiException).message
              : 'Failed to load appointments';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.labelSecondary,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(msg, style: TextStyle(color: AppColors.labelSecondary)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _load,
                  child: Text(
                    'Retry',
                    style: TextStyle(color: AppColors.Brown),
                  ),
                ),
              ],
            ),
          );
        }

        final appointments = snap.data ?? [];
        if (appointments.isEmpty) {
          return Center(
            child: Text(
              'No appointments yet.',
              style: TextStyle(color: AppColors.labelSecondary),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.Brown,
          onRefresh: () async => _load(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final apt = appointments[i] as Map<String, dynamic>;
              return _AppointmentTile(
                appointment: apt,
                onDelete: () => _delete(apt['id'] as int),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: AppColors.beige,
        appBar: AppBar(
          backgroundColor: AppColors.beige,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.Brown,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'My Appointments',
            style: AppTextStyles.heading3,
          ),
        ),
        body: _buildBody(),
      );
    }

    return Container(
      color: AppColors.beige,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'My Appointments',
              style: AppTextStyles.heading3,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}

//  APPOINTMENT TILE

class _AppointmentTile extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onDelete;

  const _AppointmentTile({required this.appointment, required this.onDelete});

  // No direct theme equivalent for the "pending" amber tone, so it stays
  // as a literal alongside the themed success/error colors.
  Color get _statusColor {
    switch (appointment['status']) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color get _statusBg {
    switch (appointment['status']) {
      case 'accepted':
        return AppColors.success.withOpacity(0.12);
      case 'rejected':
        return AppColors.error.withOpacity(0.12);
      default:
        return AppColors.warning.withOpacity(0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.Brown.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment['case_type'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.Brown,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (appointment['status'] ?? 'pending').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.gavel, text: appointment['law_type'] ?? ''),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.access_time,
            text:
                '${appointment['slot_start_time'] ?? ''} → ${appointment['slot_end_time'] ?? ''}',
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: appointment['appointment_mode'] == 'online'
                ? Icons.videocam_outlined
                : Icons.person_outline,
            text:
                '${appointment['appointment_mode'] ?? ''} · ${appointment['payment_mode'] ?? ''}',
          ),
          if (appointment['short_description'] != null &&
              (appointment['short_description'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appointment['short_description'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.labelSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (appointment['status'] == 'accepted') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your appointment has been accepted!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if (appointment['payment_amount'] != null &&
                      appointment['payment_amount'].toString() != '0.00') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Consultation Fee: Rs. ${appointment['payment_amount']}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (appointment['status'] == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                label: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.labelSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.labelSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


class _LawyerSummaryCard extends StatelessWidget {
  final Map<String, dynamic> lawyer;
  const _LawyerSummaryCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.Brown,
            child: Text(
              lawyer['initials'] ?? '',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lawyer['name'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.Brown,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                lawyer['specialty'] ?? '',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.labelSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    lawyer['location'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.labelSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
            color: AppColors.mediumBrown,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          // initialValue replaces deprecated value property
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.hint,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.Brown,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.Brown,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.labelSecondary,
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
                        ? AppColors.Brown
                        : AppColors.hintText,
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
                color: isActive ? AppColors.Brown : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.Brown
                      : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[i],
                    size: 16,
                    color: isActive ? AppColors.white : AppColors.labelSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    options[i][0].toUpperCase() + options[i].substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.white : AppColors.labelSecondary,
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

class _StepText extends StatelessWidget {
  final String text;
  const _StepText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}