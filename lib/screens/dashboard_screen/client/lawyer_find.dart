import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'appointment_screen.dart';
import 'view_appoint.dart';
import 'package:insaafconnect/routes/app_routes.dart'; // ← ADD THIS

class LawyerFindScreen extends StatefulWidget {
  const LawyerFindScreen({super.key});

  @override
  State<LawyerFindScreen> createState() => _LawyerFindScreenState();
}

class _LawyerFindScreenState extends State<LawyerFindScreen> {
  String selectedFilter = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _lawyers = [];
  bool _loading = true;
  String? _error;

  final LawyerService _lawyerService = LawyerService();

  final List<String> filters = [
    'All',
    'Civil Law',
    'Criminal Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
  ];

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _lawyerService.fetchLawyers();
      setState(() {
        _lawyers = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filtered {
    return _lawyers.where((lawyer) {
      final spec = (lawyer['specialization'] ?? '').toString();
      final matchFilter =
          selectedFilter == 'All' || spec.contains(selectedFilter);
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          (lawyer['name'] ?? '').toString().toLowerCase().contains(q) ||
          spec.toLowerCase().contains(q) ||
          (lawyer['location'] ?? '').toString().toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE5),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find a Lawyer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C23),
              ),
            ),
            Text(
              'Search for legal professionals',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8C7B6B),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, specialization, or location...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFAA9988),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFAA9988),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEADDD0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEADDD0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown, width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFF8C7B6B),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  ...filters.map((f) {
                    final isSelected = f == selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5C3D2E)),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadLawyers,
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Color(0xFF5C3D2E)),
                          ),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No lawyers found for this filter.',
                      style: TextStyle(color: Color(0xFF8C7B6B)),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _LawyerCard(lawyer: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  LAWYER CARD
// ════════════════════════════════════════════════

class _LawyerCard extends StatelessWidget {
  final Map<String, dynamic> lawyer;
  const _LawyerCard({required this.lawyer});

  Future<void> _openChat() async {
    // CORRECT — add the
    final result = await MessageService().startConversation(
      lawyerId: lawyer['id'],
    );
    if (result != null) {
      Get.toNamed(
        '/messages',
        arguments: {
          "conversation_id": result["id"],
          "other_name": lawyer["name"],
          "receiver_id": lawyer["user_id"] ?? lawyer["id"],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADDD0)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF5C3D2E),
                  child: Text(
                    (lawyer['name'] ?? 'L').toString()[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Color(0xFFE6A817),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (lawyer['rating'] ?? '0.0').toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C3D2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              (lawyer['name'] ?? 'Unknown').toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF3E2C23),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              (lawyer['specialization'] ?? '').toString(),
              style: const TextStyle(fontSize: 11, color: Color(0xFF8C7B6B)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Color(0xFF8C7B6B),
                ),
                const SizedBox(width: 3),
                Text(
                  (lawyer['location'] ?? '-').toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (lawyer['experience'] ?? '-').toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAA9988),
                  ),
                ),
                Text(
                  (lawyer['cases'] ?? '-').toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAA9988),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final fullLawyer = await LawyerService().fetchLawyerById(
                    lawyer['id'],
                  );

                  Get.to(() => LawyerProfileScreen(lawyer: fullLawyer));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openChat,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5C3D2E),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  side: const BorderSide(color: Color(0xFFDDD0C5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Chat',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  LAWYER PROFILE SCREEN
// ════════════════════════════════════════════════

class LawyerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> lawyer;
  const LawyerProfileScreen({super.key, required this.lawyer});

  Future<void> _openChat() async {
    final result = await MessageService().startConversation(
      lawyerId: lawyer['id'],
    );
    if (result != null) {
      Get.toNamed(
        AppRoutes.messages,
        arguments: {
          "conversation_id": result["id"],
          "other_name": lawyer["name"],
          "receiver_id": lawyer["user_id"] ?? lawyer["id"],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1ECE5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF3E2C23),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Lawyer Profile',
          style: TextStyle(
            color: Color(0xFF3E2C23),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEADDD0)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFF5C3D2E),
                    child: Text(
                      (lawyer['name'] ?? 'L')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    (lawyer['name'] ?? 'Unknown Lawyer').toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2C23),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    (lawyer['specialization'] ?? 'Not Available').toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8C7B6B),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Color(0xFF8C7B6B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (lawyer['location'] ?? 'Not Available').toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8C7B6B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(
                        icon: Icons.star,
                        iconColor: const Color(0xFFE6A817),
                        value: (lawyer['rating'] ?? '0.0').toString(),
                        label: 'Rating',
                      ),

                      _divider(),

                      _StatBox(
                        icon: Icons.work_outline,
                        iconColor: const Color(0xFF5C3D2E),
                        value: (lawyer['experience'] ?? '0').toString(),
                        label: 'Experience',
                      ),

                      _divider(),

                      _StatBox(
                        icon: Icons.gavel,
                        iconColor: const Color(0xFF5C3D2E),
                        value: (lawyer['cases'] ?? '0').toString(),
                        label: 'Cases',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'About',
              child: Text(
                'Specialized in ${(lawyer['specialization'] ?? 'law').toString()}.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B5B4E),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'Professional Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Experience: ${(lawyer['experience'] ?? 'Not Available')}',
                  ),
                  const SizedBox(height: 8),
                  Text('Cases: ${(lawyer['cases'] ?? 'Not Available')}'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'Contact Information',
              child: Column(
                children: [
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: (lawyer['email'] ?? 'Not Provided').toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Row 1: Book Appointment + Send Message ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => BookAppointmentScreen(lawyer: lawyer));
                    },
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openChat,
                    icon: const Icon(Icons.message_outlined, size: 18),
                    label: const Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C3D2E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFF5C3D2E),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Row 2: View Appointments + View Messages ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const ViewAppointmentsScreen());
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: const Text(
                      'View Appointments',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openChat,
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: const Text(
                      'View Messages',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C3D2E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFF5C3D2E),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: const Color(0xFFEADDD0));
}

// ════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final dynamic value;
  final String label;
  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2C23),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8C7B6B)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C23),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EDE4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.brown, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
