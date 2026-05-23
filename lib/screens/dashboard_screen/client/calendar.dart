import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime(2026, 1, 10);
  DateTime focusedMonth = DateTime(2026, 1, 1);

  final List<Map<String, dynamic>> appointments = [
    {
      'title': 'Court Hearing',
      'lawyer': 'Adv. Ahmed Khan',
      'time': '10:00 AM',
      'date': DateTime(2026, 1, 10),
      'type': 'Court',
      'color': const Color(0xFFB5651D),
      'bg': const Color(0xFFF5E6D3),
    },
    {
      'title': 'Consultation',
      'lawyer': 'Adv. Sarah Ali',
      'time': '2:00 PM',
      'date': DateTime(2026, 1, 15),
      'type': 'Meeting',
      'color': const Color(0xFF185FA5),
      'bg': const Color(0xFFE3F0FB),
    },
    {
      'title': 'Document Review',
      'lawyer': 'Adv. Bilal Ahmed',
      'time': '11:30 AM',
      'date': DateTime(2026, 1, 20),
      'type': 'Review',
      'color': const Color(0xFF2E7D32),
      'bg': const Color(0xFFE8F5E9),
    },
  ];

  List<Map<String, dynamic>> get selectedAppointments => appointments
      .where((a) =>
          (a['date'] as DateTime).year == selectedDate.year &&
          (a['date'] as DateTime).month == selectedDate.month &&
          (a['date'] as DateTime).day == selectedDate.day)
      .toList();

  List<int> get daysWithEvents {
    return appointments
        .where((a) =>
            (a['date'] as DateTime).month == focusedMonth.month &&
            (a['date'] as DateTime).year == focusedMonth.year)
        .map((a) => (a['date'] as DateTime).day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    focusedMonth = DateTime(
                        focusedMonth.year, focusedMonth.month - 1);
                  }),
                ),
                Text(
                  _monthName(focusedMonth.month) +
                      ' ${focusedMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2C23),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.brown),
                  onPressed: () => setState(() {
                    focusedMonth = DateTime(
                        focusedMonth.year, focusedMonth.month + 1);
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
          _buildCalendarGrid(),

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
                ...selectedAppointments.map((a) => _AppointmentTile(
                      appointment: a,
                    )),
                if (selectedAppointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Tap a date to view appointments',
                        style: TextStyle(
                          color: Color(0xFFAA9988),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
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
              final date =
                  DateTime(focusedMonth.year, focusedMonth.month, day);
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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3E2C23),
                          ),
                        ),
                        if (hasEvent)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.brown,
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
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF8C7B6B)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: appointment['bg'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment['type'],
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