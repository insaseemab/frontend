import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/dashboard_screen/client/payment_bottom_sheet.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  final int lawyerId;
  const ViewAppointmentsScreen({super.key, required this.lawyerId});

  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Pending', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Uses GET /appointments (no auth needed per your router)
      // then filters client-side by lawyer_id
      final data = await ApiService.getAllAppointments();
      final filtered = data
          .where((a) => a['lawyer_id'] == widget.lawyerId)
          .toList();
      setState(() {
        _appointments = filtered;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredList {
    if (_selectedFilter == 'All') return _appointments;
    return _appointments
        .where((a) =>
            (a['status'] as String).toLowerCase() ==
            _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF3E2C23), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Color(0xFF3E2C23),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3E2C23)),
            onPressed: _fetchAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status filter chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = f == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5C3D2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF5C3D2E)
                                : const Color(0xFFDDD0C5),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8C7B6B),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Body ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5C3D2E),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFF8C7B6B), size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(
                                  color: Color(0xFF8C7B6B), fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchAppointments,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C3D2E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredList.isEmpty
                        ? Center(
                            child: Text(
                              _selectedFilter == 'All'
                                  ? 'No appointments found.'
                                  : 'No ${_selectedFilter.toLowerCase()} appointments.',
                              style: const TextStyle(
                                  color: Color(0xFF8C7B6B), fontSize: 14),
                            ),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _filteredList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _AppointmentCard(appointment: _filteredList[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  APPOINTMENT CARD
// ════════════════════════════════════════════════

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  const _AppointmentCard({required this.appointment});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFE65100);
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (appointment['status'] ?? 'pending') as String;
    final startTime = appointment['slot_start_time'] ?? '';
    final endTime = appointment['slot_end_time'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Case type + status badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appointment['case_type'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2C23),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Law type ──
          _InfoRow(
            icon: Icons.gavel_outlined,
            text: '${appointment['law_type'] ?? ''} · ${appointment['case_type'] ?? ''}',
          ),
          const SizedBox(height: 6),

          // ── Time slot ──
          _InfoRow(
            icon: Icons.access_time_outlined,
            text: '$startTime  –  $endTime',
          ),
          const SizedBox(height: 6),

          // ── Mode + payment ──
          _InfoRow(
            icon: (appointment['appointment_mode'] ?? '') == 'online'
                ? Icons.laptop_outlined
                : Icons.location_on_outlined,
            text:
                '${appointment['appointment_mode'] ?? ''}  ·  ${appointment['payment_mode'] ?? ''}',
          ),

          // ── Description ──
          if ((appointment['short_description'] ?? '').toString().isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFEADDD0), height: 1),
            ),
            Text(
              appointment['short_description'],
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B5B4E),
                height: 1.5,
              ),
            ),
          ],

          // ── Payment amount ──
          if (appointment['payment_amount'] != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.payments_outlined,
              text: 'PKR ${appointment['payment_amount']}',
            ),
          ],
          if (status.toLowerCase() == "accepted" &&
    appointment['payment_amount'] != null &&
    appointment['payment_status'] != "paid")
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PaymentBottomSheet(
            appointment: appointment,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5C3D2E),
        foregroundColor: Colors.white,
      ),
      child: const Text("Proceed To Payment"),
    ),
  ),
        ],
      ),
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
        Icon(icon, size: 15, color: const Color(0xFF8C7B6B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
          ),
        ),
      ],
    );
  }
}