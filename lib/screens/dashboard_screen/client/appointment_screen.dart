import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';

// ════════════════════════════════════════════════
//  BOOK APPOINTMENT SCREEN
//  POST /appointments
// ════════════════════════════════════════════════

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> lawyer;

  const BookAppointmentScreen({super.key, required this.lawyer});

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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5C3D2E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!mounted) return; // guard after async gap

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5C3D2E)),
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
      await ApiService.createAppointment(
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            SizedBox(width: 10),
            Text('Appointment Booked!'),
          ],
        ),
        content: Text(
          'Your appointment with ${widget.lawyer['name']} has been submitted and is pending confirmation.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF5C3D2E))),
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
      backgroundColor: const Color(0xFFF1ECE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF3E2C23),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Color(0xFF3E2C23),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                    backgroundColor: const Color(0xFF5C3D2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    // withValues replaces deprecated withOpacity
                    disabledBackgroundColor: const Color(
                      0xFF5C3D2E,
                    ).withValues(alpha: 0.5),
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
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF3E2C23),
    ),
  );

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5C3D2E),
    ),
  );

  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAA9988)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEADDD0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEADDD0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
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

// ════════════════════════════════════════════════
//  MY APPOINTMENTS SCREEN
//  GET /appointments/client/:clientId
// ════════════════════════════════════════════════

class MyAppointmentsScreen extends StatefulWidget {
  final int clientId;
  const MyAppointmentsScreen({super.key, required this.clientId});

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
      _future = ApiService.getAppointmentsByClient(widget.clientId);
    });
  }

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteAppointment(id);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF3E2C23),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: Color(0xFF3E2C23),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
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
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFF8C7B6B),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(msg, style: const TextStyle(color: Color(0xFF8C7B6B))),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _load,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Color(0xFF5C3D2E)),
                    ),
                  ),
                ],
              ),
            );
          }

          final appointments = snap.data ?? [];
          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                'No appointments yet.',
                style: TextStyle(color: Color(0xFF8C7B6B)),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF5C3D2E),
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
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  APPOINTMENT TILE
// ════════════════════════════════════════════════

class _AppointmentTile extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onDelete;

  const _AppointmentTile({required this.appointment, required this.onDelete});

  Color get _statusColor {
    switch (appointment['status']) {
      case 'accepted':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFFB5651D);
    }
  }

  Color get _statusBg {
    switch (appointment['status']) {
      case 'accepted':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5E6D3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(
            // withValues replaces deprecated withOpacity
            color: Colors.brown.withValues(alpha: 0.05),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF3E2C23),
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8C7B6B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (appointment['status'] == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Color(0xFFB71C1C),
                ),
                label: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Color(0xFFB71C1C)),
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
        Icon(icon, size: 13, color: const Color(0xFF8C7B6B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════

class _LawyerSummaryCard extends StatelessWidget {
  final Map<String, dynamic> lawyer;
  const _LawyerSummaryCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF5C3D2E),
            child: Text(
              lawyer['initials'] ?? '',
              style: const TextStyle(
                color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2C23),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                lawyer['specialty'] ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Color(0xFF8C7B6B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    lawyer['location'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8C7B6B),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5C3D2E),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          // initialValue replaces deprecated value property
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFFAA9988)),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEADDD0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEADDD0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5C3D2E),
                width: 1.5,
              ),
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
          border: Border.all(color: const Color(0xFFEADDD0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF5C3D2E),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C7B6B),
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
                        ? const Color(0xFF3E2C23)
                        : const Color(0xFFAA9988),
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
                color: isActive ? const Color(0xFF5C3D2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF5C3D2E)
                      : const Color(0xFFEADDD0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[i],
                    size: 16,
                    color: isActive ? Colors.white : const Color(0xFF8C7B6B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    options[i][0].toUpperCase() + options[i].substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF8C7B6B),
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
