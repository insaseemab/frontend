import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  final _box = GetStorage();

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _fetchAppointments();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final raw = await ApiService.getMyAppointments();
    final role = _box.read<String>('role');

    return raw.map<Map<String, dynamic>>((a) {
      final apt = a as Map<String, dynamic>;

      // Role-aware name: client sees lawyer's name, lawyer sees client's name
      final otherPartyName = role == 'lawyer'
          ? (apt['client_name'] ?? 'Client')
          : (apt['lawyer_name'] ?? 'Lawyer');

      final startRaw = apt['slot_start_time']?.toString();
      DateTime? start;
      try {
        if (startRaw != null) start = DateTime.parse(startRaw);
      } catch (_) {
        start = null;
      }

      final status = (apt['status'] ?? 'pending').toString();

      return {
        'id': apt['id'],
        'title': apt['case_type'] ?? apt['law_type'] ?? 'Appointment',
        'lawyer': otherPartyName,
        'time': start != null ? _formatTime(start) : '--',
        'date': start,
        'type': status,
        'color': _statusColor(status),
        'bg': _statusBg(status),
      };
    }).where((a) => a['date'] != null).toList();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFFB5651D);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5E6D3);
    }
  }

  List<Map<String, dynamic>> _selectedAppointments(List<Map<String, dynamic>> all) => all
      .where((a) =>
          (a['date'] as DateTime).year == selectedDate.year &&
          (a['date'] as DateTime).month == selectedDate.month &&
          (a['date'] as DateTime).day == selectedDate.day)
      .toList();

  List<int> _daysWithEvents(List<Map<String, dynamic>> all) {
    return all
        .where((a) =>
            (a['date'] as DateTime).month == focusedMonth.month &&
            (a['date'] as DateTime).year == focusedMonth.year)
        .map((a) => (a['date'] as DateTime).day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
            ),
          );
        }

        if (snap.hasError) {
          final msg = snap.error is ApiException
              ? (snap.error as ApiException).message
              : 'Failed to load appointments';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFF8C7B6B), size: 48),
                  const SizedBox(height: 12),
                  Text(msg, style: const TextStyle(color: Color(0xFF8C7B6B))),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _load,
                    child: const Text('Retry', style: TextStyle(color: Color(0xFF5C3D2E))),
                  ),
                ],
              ),
            ),
          );
        }

        final appointments = snap.data ?? [];
        final selectedAppointments = _selectedAppointments(appointments);
        final daysWithEvents = _daysWithEvents(appointments);

        return RefreshIndicator(
          color: const Color(0xFF5C3D2E),
          onRefresh: () async => _load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ── Month Header ──
                Container(
                  color: const Color(0xFFF1ECE5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.brown),
                        onPressed: () => setState(() {
                          focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
                        }),
                      ),
                      Text(
                        '${_monthName(focusedMonth.month)} ${focusedMonth.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2C23),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.brown),
                        onPressed: () => setState(() {
                          focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
                        }),
                      ),
                    ],
                  ),
                ),

                // ── Day Headers ──
                Container(
                  color: const Color(0xFFF1ECE5),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8C7B6B),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Calendar Grid ──
                _buildCalendarGrid(daysWithEvents),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFEADDD0), thickness: 1, height: 1),
                const SizedBox(height: 16),

                // ── Events for selected day ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAppointments.isEmpty
                            ? 'No appointments on ${selectedDate.day} ${_monthName(selectedDate.month)}'
                            : 'Appointments on ${selectedDate.day} ${_monthName(selectedDate.month)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2C23),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedAppointments.map((a) => _AppointmentTile(appointment: a)),
                      if (selectedAppointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Tap a date to view appointments',
                              style: TextStyle(color: Color(0xFFAA9988), fontSize: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(List<int> daysWithEvents) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final totalCells = startWeekday + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - startWeekday + 1;
              if (day < 1 || day > lastDay.day) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final date = DateTime(focusedMonth.year, focusedMonth.month, day);
              final isSelected = date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;
              final hasEvent = daysWithEvents.contains(day);
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.brown
                          : isToday
                              ? const Color(0xFFF5EDE4)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF3E2C23),
                          ),
                        ),
                        if (hasEvent)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.brown,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}

class _AppointmentTile extends StatelessWidget {
  final Map<String, dynamic> appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: appointment['color'],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF3E2C23),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appointment['lawyer'],
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B6B)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                appointment['time'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF3E2C23),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: appointment['bg'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (appointment['type'] as String).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: appointment['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}