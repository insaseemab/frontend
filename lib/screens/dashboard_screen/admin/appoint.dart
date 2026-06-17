import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/admin_dashboard.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════
//  ADMIN — ALL APPOINTMENTS PAGE
// ════════════════════════════════════════════════

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  late Future<List<dynamic>> _future;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ApiService.getAllAppointments();
    });
  }

  List<dynamic> _filtered(List<dynamic> all) {
    return all.where((a) {
      final apt = a as Map<String, dynamic>;
      final matchStatus =
          _selectedFilter == 'all' ||
          (apt['status'] ?? '').toLowerCase() == _selectedFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          apt['id'].toString().contains(q) ||
          (apt['case_type'] ?? '').toLowerCase().contains(q) ||
          (apt['law_type'] ?? '').toLowerCase().contains(q) ||
          apt['client_id'].toString().contains(q) ||
          apt['lawyer_id'].toString().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── View Detail ──
  void _showDetail(Map<String, dynamic> apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(appointmentId: apt['id'] as int),
    );
  }

  Future<void> _showUpdatePaymentStatus(Map<String, dynamic> apt) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Approve Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (apt['payment_mode'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 16,
                      color: Color(0xFF5C3D2E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mode: ${apt['payment_mode']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2C23),
                      ),
                    ),
                  ],
                ),
              ),
            if (apt['payment_receipt'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receipt',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8C7B6B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apt['payment_receipt'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2C23),
                      ),
                    ),
                  ],
                ),
              ),
            if (apt['payment_amount'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Amount: Rs. ${apt['payment_amount']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            const Text(
              'Confirm you have verified the client\'s payment and want to approve it?',
              style: TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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

  // ── Edit Appointment ──
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(
                  'Lawyer ID',
                  lawyerIdCtrl,
                  keyboardType: TextInputType.number,
                ),
                _editField('Law Type', lawTypeCtrl),
                _editField('Case Type', caseTypeCtrl),
                _editField('Short Description', descCtrl, maxLines: 3),
                _editField(
                  'Slot Start Time',
                  startCtrl,
                  hint: 'YYYY-MM-DD HH:MM:SS',
                ),
                _editField(
                  'Slot End Time',
                  endCtrl,
                  hint: 'YYYY-MM-DD HH:MM:SS',
                ),

                const SizedBox(height: 8),
                // ── Mode selector ──
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
                            color: isActive
                                ? const Color(0xFF5C3D2E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF5C3D2E)
                                  : const Color(0xFFEADDD0),
                            ),
                          ),
                          child: Text(
                            m[0].toUpperCase() + m.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF8C7B6B),
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
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                    const SnackBar(
                      content: Text('Appointment updated successfully'),
                    ),
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  Get.snackbar(
                    'Error',
                    e.message,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit field helper ──
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateStatus(Map<String, dynamic> apt) async {
    String selectedStatus = apt['status'] ?? 'pending';
    final paymentCtrl = TextEditingController(
      text: apt['payment_amount']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                          border: Border.all(
                            color: isActive ? col : const Color(0xFFEADDD0),
                          ),
                        ),
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF8C7B6B),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF5C3D2E),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                    SnackBar(
                      content: Text('Status updated to $selectedStatus'),
                    ),
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  Get.snackbar(
                    'Error',
                    e.message,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () {
              Get.offAll(() => AdminDashboardScreen());
            },
          ),
        ),
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'All Appointments',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.brown),
            onPressed: _load,
          ),
        ],
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '${snap.error}',
                    style: const TextStyle(color: Colors.grey),
                  ),
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
                // ── Stats Row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: '${all.length}',
                        color: Colors.brown,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Pending',
                        value: '$pending',
                        color: const Color(0xFFB5651D),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Accepted',
                        value: '$accepted',
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Rejected',
                        value: '$rejected',
                        color: const Color(0xFFB71C1C),
                      ),
                    ],
                  ),
                ),

                // ── Search ──
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
                ),

                // ── Filter Chips ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['all', 'pending', 'accepted', 'rejected'].map((
                        f,
                      ) {
                        final isSelected = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedFilter = f),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xFF5C3D2E)
                                  : Colors.white,
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF5C3D2E)
                                      : Colors.grey.shade300,
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
                          child: Text(
                            'No appointments found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final apt = filtered[i] as Map<String, dynamic>;
                            return _AdminAppointmentCard(
                              appointment: apt,
                              onViewDetail: () => _showDetail(apt),
                              onEdit: () => _showEdit(apt),
                              onUpdateStatus: () => _showUpdateStatus(apt),
                              onUpdatePaymentStatus: () =>
                                  _showUpdatePaymentStatus(apt), // ADD THIS
                            );
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

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
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  APPOINTMENT CARD
// ════════════════════════════════════════════════
class _AdminAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onUpdateStatus;
  final VoidCallback onUpdatePaymentStatus;

  const _AdminAppointmentCard({
    required this.appointment,
    required this.onViewDetail,
    required this.onEdit,
    required this.onUpdateStatus,
    required this.onUpdatePaymentStatus,
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
    final isAccepted = appointment['status'] == 'accepted';
    final amount = appointment['payment_amount'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointment #${appointment['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF3E2C23),
                ),
              ),
              Row(
                children: [
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF5C3D2E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'status') onUpdateStatus();
                      if (value == 'detail') onViewDetail();
                      if (value == 'edit') onEdit();
                      if (value == 'payment') onUpdatePaymentStatus();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync_alt,
                              size: 16,
                              color: Color(0xFF5C3D2E),
                            ),
                            SizedBox(width: 10),
                            Text('Update Status'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: Color(0xFF5C3D2E),
                            ),
                            SizedBox(width: 10),
                            Text('View Detail'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF5C3D2E),
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'payment',
                        child: Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: Color(0xFF5C3D2E),
                            ),
                            SizedBox(width: 10),
                            Text('Update Payment Status'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Client & Lawyer IDs ──
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
          ),
          const SizedBox(height: 8),

          // ── Case details ──
          _InfoRow(
            icon: Icons.folder_outlined,
            text:
                '${appointment['case_type'] ?? ''} · ${appointment['law_type'] ?? ''}',
          ),
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
            text: appointment['appointment_mode'] ?? '',
          ),

          if (appointment['short_description'] != null &&
              (appointment['short_description'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
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

          // ── Payment amount (accepted only) ──
          if (isAccepted && amount != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Amount: Rs. $amount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
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
//  DETAIL BOTTOM SHEET
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
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
              ),
            );
          }
          if (snap.hasError) {
            return SizedBox(
              height: 200,
              child: Center(child: Text('Error: ${snap.error}')),
            );
          }

          final apt = snap.data!;
          final isAccepted = apt['status'] == 'accepted';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle bar ──
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // ── Title + Status ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Appointment #${apt['id']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2C23),
                      ),
                    ),
                    _StatusBadge(status: apt['status'] ?? 'pending'),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Parties ──
                _DetailSection(
                  title: 'Parties',
                  children: [
                    _DetailRow(
                      label: 'Client ID',
                      value: '${apt['client_id'] ?? '-'}',
                    ),
                    _DetailRow(
                      label: 'Lawyer ID',
                      value: '${apt['lawyer_id'] ?? '-'}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Case Info ──
                _DetailSection(
                  title: 'Case Info',
                  children: [
                    _DetailRow(
                      label: 'Law Type',
                      value: apt['law_type'] ?? '-',
                    ),
                    _DetailRow(
                      label: 'Case Type',
                      value: apt['case_type'] ?? '-',
                    ),
                    _DetailRow(
                      label: 'Mode',
                      value: apt['appointment_mode'] ?? '-',
                    ),
                    if (apt['short_description'] != null)
                      _DetailRow(
                        label: 'Description',
                        value: apt['short_description'],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Time Slot ──
                _DetailSection(
                  title: 'Time Slot',
                  children: [
                    _DetailRow(
                      label: 'Start',
                      value: apt['slot_start_time'] ?? '-',
                    ),
                    _DetailRow(
                      label: 'End',
                      value: apt['slot_end_time'] ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Payment ──
                if (isAccepted) ...[
                  _DetailSection(
                    title: 'Payment',
                    children: [
                      _DetailRow(
                        label: 'Amount',
                        value: 'Rs. ${apt['payment_amount'] ?? '-'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Close button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
//  DETAIL HELPER WIDGETS
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF5C3D2E),
            ),
          ),
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2C23),
              ),
            ),
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
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}

// ── Small reusable widgets ──

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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5C3D2E)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF8C7B6B)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2C23),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
