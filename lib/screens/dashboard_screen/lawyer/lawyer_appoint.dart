import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:get/get.dart';

class LawyerAppointmentsPage extends StatefulWidget {
  const LawyerAppointmentsPage({super.key});

  @override
  State<LawyerAppointmentsPage> createState() => _LawyerAppointmentsPageState();
}

class _LawyerAppointmentsPageState extends State<LawyerAppointmentsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ApiService.getMyAppointments(); // ← uses token automatically
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B4F3F)),
            );
          }
          if (snap.hasError) {
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
                  Text(
                    '${snap.error}',
                    style: const TextStyle(color: Color(0xFF8C7B6B)),
                  ),
                  TextButton(
                    onPressed: _load,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Color(0xFF6B4F3F)),
                    ),
                  ),
                ],
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'No appointments yet.',
                style: TextStyle(color: Color(0xFF8C7B6B)),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF6B4F3F),
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final apt = list[i] as Map<String, dynamic>;
                return _LawyerAppointmentTile(
                  appointment: apt,
                  onRefresh: _load,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TILE
// ─────────────────────────────────────────────────────────
class _LawyerAppointmentTile extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onRefresh;

  const _LawyerAppointmentTile({
    required this.appointment,
    required this.onRefresh,
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
    final isPending = appointment['status'] == 'pending';
    final isAccepted = appointment['status'] == 'accepted';
    final hasPayment = appointment['payment_mode'] != null;
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

          // ── Info rows ──
          _InfoRow(
            icon: Icons.person_outline,
            text:
                'Client: ${appointment['client_name'] ?? appointment['client_id']}',
          ),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.gavel, text: appointment['law_type'] ?? ''),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.access_time,
            text:
                '${appointment['slot_start_time'] ?? ''} → ${appointment['slot_end_time'] ?? ''}',
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: appointment['appointment_mode'] == 'Online'
                ? Icons.videocam_outlined
                : Icons.person_outline,
            text: appointment['appointment_mode'] ?? '',
          ),

          if ((appointment['short_description'] ?? '').isNotEmpty) ...[
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

          // ── Accept / Reject (pending only) ──
          if (isPending) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFEADDD0), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showPaymentForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],

          // ── Payment amount chip (accepted) ──
          if (isAccepted && amount != null && amount.toString() != '0.00') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
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
                    'Fee: Rs. $amount',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Client payment proof (accepted + client submitted payment) ──
          if (isAccepted && hasPayment) ...[
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
                  const Text(
                    'Client Payment Submitted',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (appointment['payment_mode'] != null)
                    _InfoRow(
                      icon: Icons.payment,
                      text: 'Mode: ${appointment['payment_mode']}',
                    ),
                  if (appointment['payment_receipt'] != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.receipt_outlined,
                      text: 'Receipt: ${appointment['payment_receipt']}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Approve Payment button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _approvePayment(context),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Approve Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reject Appointment'),
        content: const Text(
          'Are you sure you want to reject this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Yes, Reject',
              style: TextStyle(color: Color(0xFFB71C1C)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.updateAppointmentStatus(
        id: appointment['id'] as int,
        status: 'rejected',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment rejected')));
      onRefresh();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showPaymentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PaymentFormSheet(appointment: appointment, onAccepted: onRefresh),
    );
  }

  Future<void> _approvePayment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Approve Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appointment['payment_mode'] != null)
              _DetailChip(
                label: 'Mode',
                value: appointment['payment_mode'].toString(),
              ),
            if (appointment['payment_receipt'] != null)
              _DetailChip(
                label: 'Receipt',
                value: appointment['payment_receipt'].toString(),
              ),
            if (appointment['payment_amount'] != null)
              _DetailChip(
                label: 'Amount',
                value: 'Rs. ${appointment['payment_amount']}',
              ),
            const SizedBox(height: 6),
            const Text(
              'Confirm you have verified the client\'s payment?',
              style: TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
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
      await ApiService.approvePayment(id: appointment['id'] as int);
      if (!context.mounted) return;
      Get.snackbar(
        'Success',
        'Payment approved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      onRefresh();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ─────────────────────────────────────────────────────────
// PAYMENT FORM SHEET
// ─────────────────────────────────────────────────────────
class _PaymentFormSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onAccepted;

  const _PaymentFormSheet({
    required this.appointment,
    required this.onAccepted,
  });

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
      Get.snackbar(
        'Success',
        'Appointment accepted! Client has been notified.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADDD0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Set Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2C23),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'For: ${widget.appointment['case_type'] ?? ''} · ${widget.appointment['client_name'] ?? ''}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Consultation Fee (Rs.)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C3D2E),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 2000',
                  prefixText: 'Rs. ',
                  filled: true,
                  fillColor: const Color(0xFFF1ECE5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF5C3D2E),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Amount is required';
                  if (double.tryParse(v.trim()) == null)
                    return 'Enter a valid number';
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Confirm & Notify Client',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────
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
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)),
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
