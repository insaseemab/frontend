import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';

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

      // filter by status
      final matchStatus = _selectedFilter == 'all' ||
          (apt['status'] ?? '').toLowerCase() == _selectedFilter;

      // filter by search (client_id, lawyer_id, case_type, law_type)
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          apt['id'].toString().contains(q) ||
          (apt['case_type'] ?? '').toLowerCase().contains(q) ||
          (apt['law_type'] ?? '').toLowerCase().contains(q) ||
          apt['client_id'].toString().contains(q) ||
          apt['lawyer_id'].toString().contains(q);

      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
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
                child:
                    Image.asset('assets/images/logo.png', fit: BoxFit.cover),
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
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('${snap.error}',
                      style: const TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: _load,
                    child: const Text('Retry',
                        style: TextStyle(color: Color(0xFF5C3D2E))),
                  ),
                ],
              ),
            );
          }

          final all = snap.data ?? [];
          final filtered = _filtered(all);

          // stats
          final pending =
              all.where((a) => a['status'] == 'pending').length;
          final accepted =
              all.where((a) => a['status'] == 'accepted').length;
          final rejected =
              all.where((a) => a['status'] == 'rejected').length;

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
                          color: Colors.brown),
                      const SizedBox(width: 10),
                      _StatCard(
                          label: 'Pending',
                          value: '$pending',
                          color: const Color(0xFFB5651D)),
                      const SizedBox(width: 10),
                      _StatCard(
                          label: 'Accepted',
                          value: '$accepted',
                          color: const Color(0xFF2E7D32)),
                      const SizedBox(width: 10),
                      _StatCard(
                          label: 'Rejected',
                          value: '$rejected',
                          color: const Color(0xFFB71C1C)),
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
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
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
                      children: ['all', 'pending', 'accepted', 'rejected']
                          .map((f) {
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
                            child: Text(
                                f[0].toUpperCase() + f.substring(1)),
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
                          child: Text('No appointments found.',
                              style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _AdminAppointmentCard(
                            appointment:
                                filtered[i] as Map<String, dynamic>,
                          ),
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
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
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

  const _AdminAppointmentCard({required this.appointment});

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
                    color: Color(0xFF3E2C23)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  (appointment['status'] ?? 'pending').toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _statusColor),
                ),
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
                  label: 'Client ID',
                  value: '${appointment['client_id'] ?? '-'}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoChip(
                  icon: Icons.gavel,
                  label: 'Lawyer ID',
                  value: '${appointment['lawyer_id'] ?? '-'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Case details ──
          _InfoRow(
              icon: Icons.folder_outlined,
              text:
                  '${appointment['case_type'] ?? ''} · ${appointment['law_type'] ?? ''}'),
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
                  height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Payment amount (accepted only) ──
          if (isAccepted && amount != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Amount: Rs. $amount',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
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
          child: Text(text,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF8C7B6B)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

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
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8C7B6B))),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2C23))),
            ],
          ),
        ],
      ),
    );
  }
}