import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/appointments/payment_bottom_sheet.dart';
import 'package:insaafconnect/screens/appointments/admin_book_appointment.dart';
import 'package:insaafconnect/screens/appointments/ratings.dart';
import 'package:insaafconnect/core/services/api_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:get/get.dart';

enum AppointmentRole { admin, lawyer, client }

class AppointmentsPage extends StatefulWidget {
  final AppointmentRole role;

  const AppointmentsPage({super.key, required this.role});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<dynamic>> _future;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  bool get _isAdmin => widget.role == AppointmentRole.admin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _isAdmin
          ? AppointmentService.getAllAppointments()
          : AppointmentService.getMyAppointments();
    });
  }

  List<dynamic> _filtered(List<dynamic> all) {
    return all.where((a) {
      final apt = a as Map<String, dynamic>;
      final matchStatus =
          _selectedFilter == 'all' ||
          (apt['status'] ?? '').toString().toLowerCase() == _selectedFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          apt['id'].toString().contains(q) ||
          (apt['case_type'] ?? '').toString().toLowerCase().contains(q) ||
          (apt['law_type'] ?? '').toString().toLowerCase().contains(q) ||
          (apt['client_name'] ?? '').toString().toLowerCase().contains(q) ||
          (apt['lawyer_name'] ?? '').toString().toLowerCase().contains(q) ||
          (apt['client_id'] ?? '').toString().contains(q) ||
          (apt['lawyer_id'] ?? '').toString().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  void _showDetail(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(appointmentId: apt['id'] as int),
    );
  }

  Future<void> _showEdit(Map<String, dynamic> apt) async {
    final lawyerIdCtrl = TextEditingController(
      text: apt['lawyer_id']?.toString() ?? '',
    );
    final lawTypeCtrl = TextEditingController(
      text: apt['law_type']?.toString() ?? '',
    );
    final caseTypeCtrl = TextEditingController(
      text: apt['case_type']?.toString() ?? '',
    );
    final descCtrl = TextEditingController(
      text: apt['short_description']?.toString() ?? '',
    );
    final startCtrl = TextEditingController(
      text: apt['slot_start_time']?.toString() ?? '',
    );
    final endCtrl = TextEditingController(
      text: apt['slot_end_time']?.toString() ?? '',
    );
    String mode = apt['appointment_mode']?.toString() ?? 'online';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField('Lawyer ID', lawyerIdCtrl, keyboardType: TextInputType.number),
                _editField('Law Type', lawTypeCtrl),
                _editField('Case Type', caseTypeCtrl),
                _editField('Short Description', descCtrl, maxLines: 3),
                _editField('Slot Start Time', startCtrl, hint: 'YYYY-MM-DD HH:MM:SS'),
                _editField('Slot End Time', endCtrl, hint: 'YYYY-MM-DD HH:MM:SS'),
                const SizedBox(height: 8),
                Row(
                  children: ['online', 'physical'].map((m) {
                    final isActive = mode == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => mode = m),
                        child: Container(
                          margin: EdgeInsets.only(right: m == 'online' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.Brown : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive ? AppColors.Brown : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            m[0].toUpperCase() + m.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isActive ? AppColors.white : AppColors.labelSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.Brown,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Get.back();
                try {
                  await AppointmentService.editAppointment(
                    id: apt['id'] as int,
                    lawyerId: int.tryParse(lawyerIdCtrl.text.trim()) ?? 0,
                    lawType: lawTypeCtrl.text.trim(),
                    caseType: caseTypeCtrl.text.trim(),
                    shortDescription: descCtrl.text.trim(),
                    slotStartTime: startCtrl.text.trim(),
                    slotEndTime: endCtrl.text.trim(),
                    appointmentMode: mode,
                  );
                  if (!mounted) return;
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment updated successfully')),
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: AppTextStyles.hint.copyWith(fontSize: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.Brown, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Future<void> _showAdminUpdateStatus(Map<String, dynamic> apt) async {
    String selectedStatus = apt['status'] ?? 'pending';
    final paymentCtrl = TextEditingController(
      text: apt['payment_amount']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: ['pending', 'accepted', 'rejected'].map((s) {
                  final isActive = selectedStatus == s;
                  Color col = s == 'accepted'
                      ? AppColors.success
                      : s == 'rejected'
                          ? AppColors.error
                          : AppColors.warning;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => selectedStatus = s),
                      child: Container(
                        margin: EdgeInsets.only(right: s != 'rejected' ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? col : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isActive ? col : AppColors.cardBorder),
                        ),
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive ? AppColors.white : AppColors.labelSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: paymentCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Payment Amount (required if Accepted)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.Brown, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.Brown,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Get.back();
                try {
                  await AppointmentService.updateAppointmentStatus(
                    id: apt['id'] as int,
                    status: selectedStatus,
                    paymentAmount: paymentCtrl.text.trim().isEmpty
                        ? null
                        : double.tryParse(paymentCtrl.text.trim()),
                  );
                  if (!mounted) return;
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status updated to $selectedStatus')),
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _lawyerReject(Map<String, dynamic> apt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reject Appointment'),
        content: const Text('Are you sure you want to reject this appointment?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes, Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AppointmentService.updateAppointmentStatus(id: apt['id'] as int, status: 'rejected');
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment rejected')));
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _lawyerShowAcceptSheet(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentFormSheet(appointment: apt, onAccepted: _load),
    );
  }

  Future<void> _showApprovePayment(Map<String, dynamic> apt) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (apt['payment_mode'] != null)
                  _DetailChip(label: 'Mode', value: apt['payment_mode'].toString()),
                if (apt['payment_amount'] != null)
                  _DetailChip(label: 'Amount', value: 'Rs. ${apt['payment_amount']}'),
                if (apt['payment_receipt'] != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Receipt',
                      style: TextStyle(fontSize: 12, color: AppColors.labelSecondary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ReceiptPreview(raw: apt['payment_receipt'].toString()),
                ],
                const SizedBox(height: 10),
                Text(
                  'Confirm you have verified the client\'s payment and want to approve it?',
                  style: TextStyle(fontSize: 13, color: AppColors.labelSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AppointmentService.approvePayment(id: apt['id'] as int);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment approved successfully')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showConvertToCase(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConvertToCaseSheet(appointment: apt, onConverted: _load),
    );
  }

  Future<void> _clientCancel(Map<String, dynamic> apt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AppointmentService.deleteAppointment(apt['id'] as int);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _clientShowPayment(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(appointment: apt),
    ).then((_) => _load());
  }

  String get _title {
    switch (widget.role) {
      case AppointmentRole.admin:
        return 'All Appointments';
      case AppointmentRole.lawyer:
        return 'My Appointments';
      case AppointmentRole.client:
        return 'My Appointments';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.beige,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.heading3,
                ),
                Row(
                  children: [
                    if (_isAdmin)
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.Brown),
                        onPressed: () async {
                          final result = await Get.to(() => const AdminBookAppointmentScreen());
                          if (result == true) {
                            _load();
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.Brown),
                      onPressed: _load,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.Brown));
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text('${snap.error}', style: TextStyle(color: AppColors.labelSecondary)),
                        TextButton(
                          onPressed: _load,
                          child: Text('Retry', style: TextStyle(color: AppColors.Brown)),
                        ),
                      ],
                    ),
                  );
                }

                final all = snap.data ?? [];
                final filtered = _filtered(all);

                final pending = all.where((a) => a['status'] == 'pending').length;
                final accepted = all.where((a) => a['status'] == 'accepted').length;
                final rejected = all.where((a) => a['status'] == 'rejected').length;

                return RefreshIndicator(
                  color: AppColors.Brown,
                  onRefresh: () async => _load(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            _StatCard(label: 'Total', value: '${all.length}', color: AppColors.Brown),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Pending', value: '$pending', color: AppColors.warning),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Accepted', value: '$accepted', color: AppColors.success),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Rejected', value: '$rejected', color: AppColors.error),
                          ],
                        ),
                      ),
                      if (_isAdmin)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search by ID, case type, law type...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['all', 'pending', 'accepted', 'rejected'].map((f) {
                              final isSelected = _selectedFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _selectedFilter = f),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? AppColors.Brown : AppColors.white,
                                    foregroundColor: isSelected ? AppColors.white : Colors.black87,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.Brown : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Text(f[0].toUpperCase() + f.substring(1)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text('No appointments found.', style: TextStyle(color: AppColors.labelSecondary)),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final apt = filtered[i] as Map<String, dynamic>;
                                  return _AppointmentCard(
                                    appointment: apt,
                                    role: widget.role,
                                    onViewDetail: () => _showDetail(apt),
                                    onEdit: () => _showEdit(apt),
                                    onAdminUpdateStatus: () => _showAdminUpdateStatus(apt),
                                    onApprovePayment: () => _showApprovePayment(apt),
                                    onLawyerReject: () => _lawyerReject(apt),
                                    onLawyerAccept: () => _lawyerShowAcceptSheet(apt),
                                    onClientCancel: () => _clientCancel(apt),
                                    onClientPay: () => _clientShowPayment(apt),
                                    onConvertToCase: () => _showConvertToCase(apt),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final AppointmentRole role;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onAdminUpdateStatus;
  final VoidCallback onApprovePayment;
  final VoidCallback onLawyerReject;
  final VoidCallback onLawyerAccept;
  final VoidCallback onClientCancel;
  final VoidCallback onClientPay;
  final VoidCallback onConvertToCase;

  const _AppointmentCard({
    required this.appointment,
    required this.role,
    required this.onViewDetail,
    required this.onEdit,
    required this.onAdminUpdateStatus,
    required this.onApprovePayment,
    required this.onLawyerReject,
    required this.onLawyerAccept,
    required this.onClientCancel,
    required this.onClientPay,
    required this.onConvertToCase,
  });

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
    final status = (appointment['status'] ?? 'pending').toString();
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    final amount = appointment['payment_amount'];
    final hasClientPayment = appointment['payment_mode'] != null;
    final paymentApproved =
        appointment['payment_status'] == 1 || appointment['payment_status'] == true;
    final isConverted = appointment['converted_to_case'] == true ||
        appointment['converted_to_case'] == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: AppColors.Brown.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  role == AppointmentRole.admin
                      ? 'Appointment #${appointment['id']}'
                      : (appointment['case_type'] ?? '').toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.Brown),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor),
                    ),
                  ),
                  if (role == AppointmentRole.admin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: AppColors.Brown),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'status') onAdminUpdateStatus();
                        if (value == 'detail') onViewDetail();
                        if (value == 'edit') onEdit();
                        if (value == 'payment') onApprovePayment();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'status',
                          child: Row(children: [
                            Icon(Icons.sync_alt, size: 16, color: AppColors.Brown),
                            const SizedBox(width: 10),
                            const Text('Update Status'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(children: [
                            Icon(Icons.visibility_outlined, size: 16, color: AppColors.Brown),
                            const SizedBox(width: 10),
                            const Text('View Detail'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 16, color: AppColors.Brown),
                            const SizedBox(width: 10),
                            const Text('Edit'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'payment',
                          child: Row(children: [
                            Icon(Icons.payments_outlined, size: 16, color: AppColors.Brown),
                            const SizedBox(width: 10),
                            const Text('Update Payment Status'),
                          ]),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (role == AppointmentRole.admin)
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.person_outline,
                    label: 'Client',
                    value: '${appointment['client_name'] ?? '-'}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.gavel,
                    label: 'Lawyer',
                    value: '${appointment['lawyer_name'] ?? '-'}',
                  ),
                ),
              ],
            )
          else if (role == AppointmentRole.lawyer)
            _InfoRow(
              icon: Icons.person_outline,
              text: 'Client: ${appointment['client_name'] ?? appointment['client_id']}',
            )
          else
            _InfoRow(
              icon: Icons.gavel,
              text: 'Lawyer: ${appointment['lawyer_name'] ?? appointment['lawyer_id']}',
            ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.folder_outlined,
            text: '${appointment['case_type'] ?? ''} · ${appointment['law_type'] ?? ''}',
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.access_time,
            text: '${appointment['slot_start_time'] ?? ''} → ${appointment['slot_end_time'] ?? ''}',
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: (appointment['appointment_mode'] ?? '').toString().toLowerCase() == 'online'
                ? Icons.videocam_outlined
                : Icons.person_outline,
            text: appointment['appointment_mode'] ?? '',
          ),
          if ((appointment['short_description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              appointment['short_description'],
              style: TextStyle(fontSize: 12, color: AppColors.labelSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (isAccepted && amount != null && amount.toString() != '0.00') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.payments_outlined, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Amount: Rs. $amount',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
          if (role == AppointmentRole.lawyer && isPending) ...[
            const SizedBox(height: 14),
            Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onLawyerReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onLawyerAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Brown,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if ((role == AppointmentRole.lawyer || role == AppointmentRole.admin) &&
              isAccepted && hasClientPayment && !paymentApproved) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Client Payment Submitted',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.Brown)),
                  const SizedBox(height: 6),
                  if (appointment['payment_mode'] != null)
                    _InfoRow(icon: Icons.payment, text: 'Mode: ${appointment['payment_mode']}'),
                  if (appointment['payment_receipt'] != null) ...[
                    const SizedBox(height: 4),
                    const _InfoRow(icon: Icons.receipt_outlined, text: 'Receipt attached'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onApprovePayment,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Approve Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
          if (role == AppointmentRole.client && isPending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClientCancel,
                icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                label: Text('Cancel',
                    style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ),
          ],
          if (role == AppointmentRole.client && isAccepted && amount != null && !hasClientPayment) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClientPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Brown,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Proceed To Payment'),
              ),
            ),
          ],
          if (role == AppointmentRole.client && isAccepted && hasClientPayment && !paymentApproved) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Payment submitted — waiting for lawyer approval',
                style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if ((role == AppointmentRole.admin || role == AppointmentRole.lawyer) &&
              isAccepted && paymentApproved && !isConverted) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onConvertToCase,
                icon: Icon(Icons.cases_outlined, size: 16, color: AppColors.Brown),
                label: Text(
                  'Convert to Case',
                  style: TextStyle(color: AppColors.Brown, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.Brown),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          if (isConverted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Converted to Case',
                    style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          if (role == AppointmentRole.client && isAccepted && paymentApproved && (isConverted || appointment['case_status'] == 'closed' || appointment['case_status'] == 'completed')) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => RatingBottomSheet(appointment: appointment),
                  );
                },
                icon: const Icon(Icons.star_outline, size: 16),
                label: const Text('Rate Lawyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final int appointmentId;
  const _DetailSheet({required this.appointmentId});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppointmentService.getAppointmentById(widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: AppColors.Brown)),
            ));
          }
          if (snap.hasError) {
            return SizedBox(height: 200, child: Center(child: Text('Error: ${snap.error}')));
          }

          final apt = snap.data!;
          final isAccepted = apt['status'] == 'accepted';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Appointment #${apt['id']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.Brown)),
                    _StatusBadge(status: apt['status'] ?? 'pending'),
                  ],
                ),
                const SizedBox(height: 20),
                _DetailSection(
                  title: 'Parties',
                  children: [
                    _DetailRow(label: 'Client', value: '${apt['client_name'] ?? apt['client_id'] ?? '-'}'),
                    _DetailRow(label: 'Lawyer', value: '${apt['lawyer_name'] ?? apt['lawyer_id'] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Case Info',
                  children: [
                    _DetailRow(label: 'Law Type', value: apt['law_type'] ?? '-'),
                    _DetailRow(label: 'Case Type', value: apt['case_type'] ?? '-'),
                    _DetailRow(label: 'Mode', value: apt['appointment_mode'] ?? '-'),
                    if (apt['short_description'] != null)
                      _DetailRow(label: 'Description', value: apt['short_description']),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Time Slot',
                  children: [
                    _DetailRow(label: 'Start', value: apt['slot_start_time'] ?? '-'),
                    _DetailRow(label: 'End', value: apt['slot_end_time'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 12),
                if (isAccepted) ...[
                  _DetailSection(
                    title: 'Payment',
                    children: [
                      _DetailRow(label: 'Amount', value: 'Rs. ${apt['payment_amount'] ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Brown,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentFormSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onAccepted;

  const _PaymentFormSheet({required this.appointment, required this.onAccepted});

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AppointmentService.updateAppointmentStatus(
        id: widget.appointment['id'] as int,
        status: 'accepted',
        paymentAmount: double.parse(_amountCtrl.text.trim()),
      );
      if (!mounted) return;
      Get.back();
      Get.snackbar('Success', 'Appointment accepted! Client has been notified.',
          snackPosition: SnackPosition.BOTTOM);
      widget.onAccepted();
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Set Payment Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.Brown)),
              const SizedBox(height: 4),
              Text(
                'For: ${widget.appointment['case_type'] ?? ''} · ${widget.appointment['client_name'] ?? ''}',
                style: TextStyle(fontSize: 13, color: AppColors.labelSecondary),
              ),
              const SizedBox(height: 20),
              Text('Consultation Fee (Rs.)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mediumBrown)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 2000',
                  prefixText: 'Rs. ',
                  filled: true,
                  fillColor: AppColors.beige,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.Brown, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Brown,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                        )
                      : const Text('Confirm & Notify Client',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mediumBrown)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.labelSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.Brown)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color get _bg {
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _color)),
    );
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
          child: Text(text,
              style: TextStyle(fontSize: 12, color: AppColors.labelSecondary), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.Brown),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: AppColors.labelSecondary)),
              Text(value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.Brown)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  const _DetailChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, color: AppColors.labelSecondary)),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.Brown)),
          ),
        ],
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  final String raw;
  const _ReceiptPreview({required this.raw});

  Uint8List? get _bytes {
    try {
      final cleaned = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;

    if (bytes == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Receipt attached (unable to preview)',
          style: TextStyle(fontSize: 12, color: AppColors.labelSecondary),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(
        bytes,
        height: 220,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 100,
          alignment: Alignment.center,
          color: AppColors.beige,
          child: Text(
            'Unable to load receipt image',
            style: TextStyle(fontSize: 12, color: AppColors.labelSecondary),
          ),
        ),
      ),
    );
  }
}

class _ConvertToCaseSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onConverted;

  const _ConvertToCaseSheet({required this.appointment, required this.onConverted});

  @override
  State<_ConvertToCaseSheet> createState() => _ConvertToCaseSheetState();
}

class _ConvertToCaseSheetState extends State<_ConvertToCaseSheet> {
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await AppointmentService.convertToCase(id: widget.appointment['id'] as int);
      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Case Created',
        'Appointment #${widget.appointment['id']} has been converted to a case.',
        snackPosition: SnackPosition.BOTTOM,
      );
      widget.onConverted();
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Convert to Case',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.Brown),
          ),
          const SizedBox(height: 4),
          Text(
            'Appointment #${apt['id']}  ·  ${apt['client_name'] ?? ''}',
            style: TextStyle(fontSize: 13, color: AppColors.labelSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The following will be carried over:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mediumBrown),
                ),
                const SizedBox(height: 10),
                _SummaryRow(label: 'Case Type',   value: apt['case_type']?.toString()         ?? '-'),
                _SummaryRow(label: 'Law Type',    value: apt['law_type']?.toString()          ?? '-'),
                _SummaryRow(label: 'Description', value: apt['short_description']?.toString() ?? '-'),
                _SummaryRow(label: 'Client',      value: apt['client_name']?.toString()       ?? '-'),
                _SummaryRow(label: 'Lawyer',      value: apt['lawyer_name']?.toString()       ?? '-'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Client contact details will be pulled automatically from their profile.',
              style: TextStyle(fontSize: 12, color: AppColors.labelSecondary),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.cases_outlined, size: 18),
              label: Text(_isLoading ? 'Creating Case...' : 'Confirm & Create Case'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.Brown,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.labelSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.Brown),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}