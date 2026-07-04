import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/appointment_services.dart';
import 'package:insaafconnect/screens/appointments/admin_book_appointment.dart';
import 'package:insaafconnect/screens/appointments/appointment_screen.dart';
import 'package:insaafconnect/core/services/cases_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:get/get.dart';

class CalendarScreen extends StatefulWidget {
  final bool isNested;
  const CalendarScreen({super.key, this.isNested = false});

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
      _future = _fetchAppointments().then((list) {
        if (list.isNotEmpty && mounted) {
          final hasEventInCurrentMonth = list.any((a) =>
              (a['date'] as DateTime).month == focusedMonth.month &&
              (a['date'] as DateTime).year == focusedMonth.year);

          if (!hasEventInCurrentMonth) {
            final now = DateTime.now();
            final futureEvents = list.where((a) => (a['date'] as DateTime).isAfter(now)).toList();
            final targetEvent = futureEvents.isNotEmpty ? futureEvents.first : list.first;
            final targetDate = targetEvent['date'] as DateTime;
            
            setState(() {
              selectedDate = targetDate;
              focusedMonth = DateTime(targetDate.year, targetDate.month, 1);
            });
          }
        }
        return list;
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final raw = await ApiService.getMyAppointments();
    final role = _box.read<String>('role');

    return raw.map<Map<String, dynamic>>((a) {
      final apt = a as Map<String, dynamic>;

      // Role-aware name: client sees lawyer's name, lawyer/admin see client's name
      final otherPartyName = role == 'lawyer'
          ? (apt['client_name'] ?? 'Client')
          : role == 'admin'
              ? '${apt['client_name'] ?? 'Client'} → ${apt['lawyer_name'] ?? 'Lawyer'}'
              : (apt['lawyer_name'] ?? 'Lawyer');

      final dateRaw = apt['date']?.toString();
      final timeRaw = apt['slot_start_time']?.toString();
      DateTime? start;
      try {
        if (timeRaw != null && timeRaw.contains(RegExp(r'\d{4}-\d{2}-\d{2}'))) {
          // If slot_start_time is already a full ISO/datetime string, parse it directly
          start = DateTime.parse(timeRaw.replaceAll(' ', 'T'));
        } else if (dateRaw != null) {
          // Extract date part (e.g. "2026-12-28" from "2026-12-28T00:00:00.000Z")
          final datePart = dateRaw.split(RegExp('[T ]'))[0];
          if (timeRaw != null && timeRaw.trim().isNotEmpty) {
            final timePart = timeRaw.contains(':') ? timeRaw.split(' ').last : timeRaw;
            start = DateTime.parse('${datePart}T$timePart');
          } else {
            start = DateTime.parse(datePart);
          }
        }
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
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success.withOpacity(0.12);
      case 'rejected':
        return AppColors.error.withOpacity(0.12);
      default:
        return AppColors.warning.withOpacity(0.12);
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

  Future<void> _showClientBookingDialog(DateTime date) async {
    try {
      final lawyers = await CasesService.fetchLawyers();
      if (!mounted) return;
      
      Map<String, dynamic>? selectedLawyer;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFF1ECE5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a Lawyer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2C23),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      hint: const Text('Choose a lawyer'),
                      value: selectedLawyer,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFEADDD0)),
                        ),
                      ),
                      items: lawyers.map((l) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: l,
                          child: Text(l['name'] ?? 'Unknown Lawyer'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedLawyer = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedLawyer == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                Get.to(() => BookAppointmentScreen(
                                      lawyer: selectedLawyer!,
                                      initialDate: date,
                                    ))?.then((val) {
                                  if (val == true) {
                                    _load();
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C3D2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: const Color(0xFF5C3D2E).withValues(alpha: 0.5),
                        ),
                        child: const Text('Proceed to Book'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lawyers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _box.read<String>('role');
    final content = FutureBuilder<List<Map<String, dynamic>>>(
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
                Container(
                  color: AppColors.beige,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: AppColors.darkBrown),
                        onPressed: () => setState(() {
                          focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
                        }),
                      ),
                      Text(
                        '${_monthName(focusedMonth.month)} ${focusedMonth.year}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: AppColors.darkBrown),
                        onPressed: () => setState(() {
                          focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
                        }),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.beige,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBrown.withOpacity(0.65),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                _buildCalendarGrid(daysWithEvents),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFEADDD0), thickness: 1, height: 1),
                const SizedBox(height: 16),
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
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            'No appointments scheduled for this date.',
                            style: TextStyle(color: Color(0xFFAA9988), fontSize: 14),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (role != 'lawyer')
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (role == 'admin') {
                              final result = await Get.to(() => AdminBookAppointmentScreen(initialDate: selectedDate));
                              if (result == true) {
                                _load();
                              }
                            } else {
                              _showClientBookingDialog(selectedDate);
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            'Book Appointment for ${_monthName(selectedDate.month)} ${selectedDate.day}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C3D2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    if (widget.isNested) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Calendar',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: content,
    );
  }

  Widget _buildCalendarGrid(List<int> daysWithEvents) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
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