import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/appointments/payment_bottom_sheet.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════
//  ONE PAGE FOR ALL ROLES — ADMIN / LAWYER / CLIENT
//  Pass `role:` to control data source + which actions show.
// ════════════════════════════════════════════════

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
      // Admin sees everyone's appointments. Lawyer/Client see only their own —
      // the backend's /appointments/mine route already branches by req.user.role.
      _future = _isAdmin
          ? ApiService.getAllAppointments()
          : ApiService.getMyAppointments();
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
          apt['client_id'].toString().contains(q) ||
          apt['lawyer_id'].toString().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── View Detail (admin only) ──
  void _showDetail(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(appointmentId: apt['id'] as int),
    );
  }

  // ── Edit Appointment (admin only) ──
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
                            color: isActive ? const Color(0xFF5C3D2E) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive ? const Color(0xFF5C3D2E) : const Color(0xFFEADDD0),
                            ),
                          ),
                          child: Text(
                            m[0].toUpperCase() + m.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isActive ? Colors.white : const Color(0xFF8C7B6B),
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
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Get.back();
                try {
                  await ApiService.editAppointment(
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
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFFAA9988)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  // ── Update Status: admin gets full dialog (status + pay amount). ──
  // ── Lawyer: reject directly, accept via payment-amount sheet.    ──
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
                      ? const Color(0xFF2E7D32)
                      : s == 'rejected'
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFFB5651D);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => selectedStatus = s),
                      child: Container(
                        margin: EdgeInsets.only(right: s != 'rejected' ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? col : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isActive ? col : const Color(0xFFEADDD0)),
                        ),
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF8C7B6B),
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
                    borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
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
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Get.back();
                try {
                  await ApiService.updateAppointmentStatus(
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
            child: const Text('Yes, Reject', style: TextStyle(color: Color(0xFFB71C1C))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.updateAppointmentStatus(id: apt['id'] as int, status: 'rejected');
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

  // ── Approve Payment (admin + lawyer) ──
  Future<void> _showApprovePayment(Map<String, dynamic> apt) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (apt['payment_mode'] != null)
              _DetailChip(label: 'Mode', value: apt['payment_mode'].toString()),
            if (apt['payment_receipt'] != null)
              _DetailChip(label: 'Receipt', value: apt['payment_receipt'].toString()),
            if (apt['payment_amount'] != null)
              _DetailChip(label: 'Amount', value: 'Rs. ${apt['payment_amount']}'),
            const SizedBox(height: 6),
            const Text(
              'Confirm you have verified the client\'s payment and want to approve it?',
              style: TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
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
      await ApiService.approvePayment(id: apt['id'] as int);
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
// ── Convert appointment → case (admin + lawyer only) ──
void _showConvertToCase(Map<String, dynamic> apt) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConvertToCaseSheet(appointment: apt, onConverted: _load),
  );
}
  // ── Client: cancel a pending appointment ──
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
            child: const Text('Yes, Cancel', style: TextStyle(color: Color(0xFFB71C1C))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.deleteAppointment(apt['id'] as int);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Client: pay ──
  void _clientShowPayment(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(appointment: apt),
    ).then((_) => _load()); // refresh after the sheet closes either way
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _title,
          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.brown), onPressed: _load),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C3D2E)));
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('${snap.error}', style: const TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: _load,
                    child: const Text('Retry', style: TextStyle(color: Color(0xFF5C3D2E))),
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
            color: const Color(0xFF5C3D2E),
            onRefresh: () async => _load(),
            child: Column(
              children: [
                // ── Stats Row (shown for everyone — useful context) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _StatCard(label: 'Total', value: '${all.length}', color: Colors.brown),
                      const SizedBox(width: 10),
                      _StatCard(label: 'Pending', value: '$pending', color: const Color(0xFFB5651D)),
                      const SizedBox(width: 10),
                      _StatCard(label: 'Accepted', value: '$accepted', color: const Color(0xFF2E7D32)),
                      const SizedBox(width: 10),
                      _StatCard(label: 'Rejected', value: '$rejected', color: const Color(0xFFB71C1C)),
                    ],
                  ),
                ),

                // ── Search (admin only — lawyer/client lists are small enough not to need it) ──
                if (_isAdmin)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by ID, case type, law type...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
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

                // ── Filter Chips (everyone) ──
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
                              backgroundColor: isSelected ? const Color(0xFF5C3D2E) : Colors.white,
                              foregroundColor: isSelected ? Colors.white : Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF5C3D2E) : Colors.grey.shade300,
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

                // ── List ──
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No appointments found.', style: TextStyle(color: Colors.grey)),
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
  onConvertToCase: () => _showConvertToCase(apt), );// ← add this

                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  STAT CARD
// ════════════════════════════════════════════════
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  ONE CARD, ROLE-AWARE FOOTER
// ════════════════════════════════════════════════
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
  final VoidCallback onConvertToCase;   // ← add this line

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
    final status = (appointment['status'] ?? 'pending').toString();
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    final amount = appointment['payment_amount'];
    final hasClientPayment = appointment['payment_mode'] != null;
    final paymentApproved =
        appointment['payment_status'] == 1 || appointment['payment_status'] == true;
    final isConverted = appointment['converted_to_case'] == true ||  // ← add here
        appointment['converted_to_case'] == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(color: Colors.brown.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: title + status + admin menu ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  role == AppointmentRole.admin
                      ? 'Appointment #${appointment['id']}'
                      : (appointment['case_type'] ?? '').toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2C23)),
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
                  // ── Admin gets the "..." power menu. Lawyer/client use inline buttons below. ──
                  if (role == AppointmentRole.admin)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF5C3D2E)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'status') onAdminUpdateStatus();
                        if (value == 'detail') onViewDetail();
                        if (value == 'edit') onEdit();
                        if (value == 'payment') onApprovePayment();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'status',
                          child: Row(children: [
                            Icon(Icons.sync_alt, size: 16, color: Color(0xFF5C3D2E)),
                            SizedBox(width: 10),
                            Text('Update Status'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(children: [
                            Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF5C3D2E)),
                            SizedBox(width: 10),
                            Text('View Detail'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 16, color: Color(0xFF5C3D2E)),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'payment',
                          child: Row(children: [
                            Icon(Icons.payments_outlined, size: 16, color: Color(0xFF5C3D2E)),
                            SizedBox(width: 10),
                            Text('Update Payment Status'),
                          ]),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Client & Lawyer names (admin sees both; lawyer sees client; client sees lawyer) ──
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

          // ── Case details (everyone) ──
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
            // NOTE: backend always stores lowercase 'online' | 'physical' — compare lowercase.
            icon: (appointment['appointment_mode'] ?? '').toString().toLowerCase() == 'online'
                ? Icons.videocam_outlined
                : Icons.person_outline,
            text: appointment['appointment_mode'] ?? '',
          ),

          if ((appointment['short_description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              appointment['short_description'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B), height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Payment amount chip (accepted, everyone) ──
          if (isAccepted && amount != null && amount.toString() != '0.00') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Amount: Rs. $amount',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ],

          // ════════ ROLE-SPECIFIC ACTION ZONE ════════

          // ── LAWYER: Accept / Reject (pending) ──
          if (role == AppointmentRole.lawyer && isPending) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFEADDD0), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onLawyerReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
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
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],

          // ── LAWYER (or ADMIN): client submitted payment proof, needs approval ──
          if ((role == AppointmentRole.lawyer || role == AppointmentRole.admin) &&
              isAccepted && hasClientPayment && !paymentApproved) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFE6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEADDD0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Client Payment Submitted',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5C3D2E))),
                  const SizedBox(height: 6),
                  if (appointment['payment_mode'] != null)
                    _InfoRow(icon: Icons.payment, text: 'Mode: ${appointment['payment_mode']}'),
                  if (appointment['payment_receipt'] != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(icon: Icons.receipt_outlined, text: 'Receipt: ${appointment['payment_receipt']}'),
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
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],

          // ── CLIENT: Cancel (pending) ──
          if (role == AppointmentRole.client && isPending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClientCancel,
                icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFB71C1C)),
                label: const Text('Cancel',
                    style: TextStyle(color: Color(0xFFB71C1C), fontSize: 13, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ),
          ],

          // ── CLIENT: Pay (accepted, not yet paid) ──
          if (role == AppointmentRole.client && isAccepted && amount != null && !hasClientPayment) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClientPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Proceed To Payment'),
              ),
            ),
          ],
// ── CLIENT: payment submitted, waiting on lawyer ──
          if (role == AppointmentRole.client && isAccepted && hasClientPayment && !paymentApproved) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
              child: const Text(
                'Payment submitted — waiting for lawyer approval',
                style: TextStyle(fontSize: 12, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
              ),
            ),
          ],

          // ── ADMIN / LAWYER: Convert to Case (accepted, payment approved, not yet converted) ──
          if ((role == AppointmentRole.admin || role == AppointmentRole.lawyer) &&
              isAccepted && paymentApproved && !isConverted) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onConvertToCase,
                icon: const Icon(Icons.cases_outlined, size: 16, color: Color(0xFF5C3D2E)),
                label: const Text(
                  'Convert to Case',
                  style: TextStyle(color: Color(0xFF5C3D2E), fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5C3D2E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],

          // ── Already converted badge ──
          if (isConverted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Text(
                    'Converted to Case',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// ════════════════════════════════════════════════
//  DETAIL BOTTOM SHEET (admin only)
// ════════════════════════════════════════════════
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
    _future = ApiService.getAppointmentById(widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF5C3D2E))),
            );
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2C23))),
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
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
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

// ════════════════════════════════════════════════
//  PAYMENT FORM SHEET (lawyer: accept + set fee)
// ════════════════════════════════════════════════
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
      await ApiService.updateAppointmentStatus(
        id: widget.appointment['id'] as int,
        status: 'accepted',
        paymentAmount: double.parse(_amountCtrl.text.trim()),
      );
      if (!mounted) return;
      Get.back(); // close the sheet
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  decoration: BoxDecoration(color: const Color(0xFFEADDD0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Set Payment Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2C23))),
              const SizedBox(height: 4),
              Text(
                'For: ${widget.appointment['case_type'] ?? ''} · ${widget.appointment['client_name'] ?? ''}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
              ),
              const SizedBox(height: 20),
              const Text('Consultation Fee (Rs.)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5C3D2E))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 2000',
                  prefixText: 'Rs. ',
                  filled: true,
                  fillColor: const Color(0xFFF1ECE5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
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
                    backgroundColor: const Color(0xFF5C3D2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
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

// ════════════════════════════════════════════════
//  SHARED SMALL WIDGETS
//  (previously duplicated 3-4x across separate files)
// ════════════════════════════════════════════════

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5C3D2E))),
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
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3E2C23))),
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
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFFB5651D);
    }
  }

  Color get _bg {
    switch (status) {
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
        Icon(icon, size: 13, color: const Color(0xFF8C7B6B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)), overflow: TextOverflow.ellipsis),
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
      decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5C3D2E)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8C7B6B))),
              Text(value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3E2C23))),
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
      decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B))),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3E2C23))),
          ),
        ],
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
      await ApiService.convertToCase(id: widget.appointment['id'] as int);
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: const Color(0xFFEADDD0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Convert to Case',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2C23)),
          ),
          const SizedBox(height: 4),
          Text(
            'Appointment #${apt['id']}  ·  ${apt['client_name'] ?? ''}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEADDD0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The following will be carried over:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5C3D2E)),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Client contact details will be pulled automatically from their profile.',
              style: TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.cases_outlined, size: 18),
              label: Text(_isLoading ? 'Creating Case...' : 'Confirm & Create Case'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
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
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3E2C23)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}