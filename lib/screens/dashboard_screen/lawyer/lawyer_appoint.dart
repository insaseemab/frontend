import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';

class LawyerAppointmentsPage extends StatefulWidget {
  final int lawyerId;
  const LawyerAppointmentsPage({super.key, required this.lawyerId});

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
      _future = ApiService.getAppointmentsForLawyer(widget.lawyerId);
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
                  const Icon(Icons.error_outline, color: Color(0xFF8C7B6B), size: 48),
                  const SizedBox(height: 12),
                  Text('${snap.error}', style: const TextStyle(color: Color(0xFF8C7B6B))),
                  TextButton(
                    onPressed: _load,
                    child: const Text('Retry', style: TextStyle(color: Color(0xFF6B4F3F))),
                  ),
                ],
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text('No appointments yet.', style: TextStyle(color: Color(0xFF8C7B6B))),
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
// TILE — shows each appointment with Accept / Reject buttons
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
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFB71C1C);
      default:         return const Color(0xFFB5651D);
    }
  }

  Color get _statusBg {
    switch (appointment['status']) {
      case 'accepted': return const Color(0xFFE8F5E9);
      case 'rejected': return const Color(0xFFFFEBEE);
      default:         return const Color(0xFFF5E6D3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = appointment['status'] == 'pending';

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
          // ── Header row ──
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

          // ── Client name ──
          _InfoRow(
            icon: Icons.person_outline,
            text: 'Client: ${appointment['client_name'] ?? appointment['client_id']}',
          ),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.gavel, text: appointment['law_type'] ?? ''),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.access_time,
            text: '${appointment['slot_start_time'] ?? ''} → ${appointment['slot_end_time'] ?? ''}',
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B), height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Accept / Reject buttons (only when pending) ──
          if (isPending) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFEADDD0), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                // REJECT
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
                // ACCEPT
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

          // ── Show payment amount if accepted ──
          if (appointment['status'] == 'accepted' &&
              appointment['payment_amount'] != null &&
              appointment['payment_amount'].toString() != '0.00') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Fee: Rs. ${appointment['payment_amount']}',
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
        content: const Text('Are you sure you want to reject this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Reject', style: TextStyle(color: Color(0xFFB71C1C))),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rejected')),
      );
      onRefresh();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _showPaymentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentFormSheet(
        appointment: appointment,
        onAccepted: onRefresh,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PAYMENT FORM — bottom sheet shown when lawyer taps Accept
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
  String _paymentMode = 'Manual';
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
      Navigator.pop(context); // close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment accepted! Client has been notified.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      widget.onAccepted();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
              // Handle bar
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

              // Amount field
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    borderSide: const BorderSide(color: Color(0xFF5C3D2E), width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment mode selector
              const Text(
                'Payment Mode',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C3D2E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Manual', 'Stripe'].map((mode) {
                  final isSelected = _paymentMode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _paymentMode = mode),
                      child: Container(
                        margin: EdgeInsets.only(right: mode == 'Manual' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF5C3D2E) : const Color(0xFFF1ECE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF8C7B6B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Confirm button
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
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Confirm & Notify Client',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
// REUSABLE
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