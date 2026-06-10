import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
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

  final List<String> filters = [
    'All',
    'Civil Law',
    'Criminal Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
  ];

  final List<Map<String, dynamic>> lawyers = [
    {
      'id': 1,
      'name': 'Adv. Ahmed Khan',
      'initials': 'A',
      'specialty': 'Civil Law',
      'location': 'Lahore',
      'experience': '15 years exp.',
      'cases': '250 cases',
      'rating': '4.8',
      'bio':
          'Experienced civil lawyer with 15 years of practice in Lahore High Court. Specializes in property disputes, contract law, and civil litigation.',
      'phone': '+92 300 1234567',
      'email': 'ahmed.khan@insaaf.pk',
      'education': 'LLB – University of Punjab',
      'wins': '210',
    },
    {
      'id': 2,
      'name': 'Adv. Sarah Ali',
      'initials': 'S',
      'specialty': 'Corporate Law',
      'location': 'Karachi',
      'experience': '10 years exp.',
      'cases': '180 cases',
      'rating': '4.9',
      'bio':
          'Corporate law expert advising startups and enterprises on mergers, acquisitions, and compliance matters across Pakistan.',
      'phone': '+92 321 9876543',
      'email': 'sarah.ali@insaaf.pk',
      'education': 'LLM – Karachi University',
      'wins': '160',
    },
    {
      'id': 3,
      'name': 'Adv. Bilal Ahmed',
      'initials': 'B',
      'specialty': 'Criminal Law',
      'location': 'Islamabad',
      'experience': '12 years exp.',
      'cases': '200 cases',
      'rating': '4.7',
      'bio':
          'Criminal defense attorney with extensive experience in high-profile cases at the Islamabad High Court and Supreme Court of Pakistan.',
      'phone': '+92 333 4561234',
      'email': 'bilal.ahmed@insaaf.pk',
      'education': 'LLB – Quaid-e-Azam University',
      'wins': '170',
    },
    {
      'id': 4,
      'name': 'Adv. Fatima Malik',
      'initials': 'F',
      'specialty': 'Family Law',
      'location': 'Lahore',
      'experience': '8 years exp.',
      'cases': '150 cases',
      'rating': '4.6',
      'bio':
          'Compassionate family lawyer handling divorce, custody, inheritance, and domestic matters with sensitivity and professionalism.',
      'phone': '+92 345 6789012',
      'email': 'fatima.malik@insaaf.pk',
      'education': 'LLB – University of the Punjab',
      'wins': '130',
    },
    {
      'id': 5,
      'name': 'Adv. Hassan Raza',
      'initials': 'H',
      'specialty': 'Property Law',
      'location': 'Karachi',
      'experience': '20 years exp.',
      'cases': '300 cases',
      'rating': '4.9',
      'bio':
          'Senior property lawyer with two decades of handling land disputes, title transfers, and real estate transactions across Sindh.',
      'phone': '+92 300 9998887',
      'email': 'hassan.raza@insaaf.pk',
      'education': 'LLM – University of Karachi',
      'wins': '275',
    },
    {
      'id': 6,
      'name': 'Adv. Ayesha Khan',
      'initials': 'A',
      'specialty': 'Civil Law',
      'location': 'Islamabad',
      'experience': '7 years exp.',
      'cases': '120 cases',
      'rating': '4.5',
      'bio':
          'Civil litigation specialist with a focus on consumer protection and administrative law cases in federal courts.',
      'phone': '+92 311 2223334',
      'email': 'ayesha.khan@insaaf.pk',
      'education': 'LLB – International Islamic University',
      'wins': '100',
    },
  ];

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == 'All') return lawyers;
    return lawyers.where((l) => l['specialty'] == selectedFilter).toList();
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
            child: filtered.isEmpty
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
                          childAspectRatio: 0.72,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF5C3D2E),
                  child: Text(
                    lawyer['initials'],
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
                        lawyer['rating'],
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
              lawyer['name'],
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
              lawyer['specialty'],
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
                  lawyer['location'],
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
                  lawyer['experience'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAA9988),
                  ),
                ),
                Text(
                  lawyer['cases'],
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LawyerProfileScreen(lawyer: lawyer),
                    ),
                  );
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
            Icons.arrow_back_ios_new,
            color: Color(0xFF3E2C23),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
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
            // ── Profile header ──
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
                      lawyer['initials'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lawyer['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2C23),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lawyer['specialty'],
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
                        lawyer['location'],
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
                        value: lawyer['rating'],
                        label: 'Rating',
                      ),
                      _divider(),
                      _StatBox(
                        icon: Icons.work_outline,
                        iconColor: const Color(0xFF5C3D2E),
                        value: lawyer['experience'].replaceAll(' exp.', ''),
                        label: 'Experience',
                      ),
                      _divider(),
                      _StatBox(
                        icon: Icons.gavel,
                        iconColor: const Color(0xFF5C3D2E),
                        value: lawyer['cases'].replaceAll(' cases', ''),
                        label: 'Cases',
                      ),
                      _divider(),
                      _StatBox(
                        icon: Icons.emoji_events_outlined,
                        iconColor: const Color(0xFF2E7D32),
                        value: lawyer['wins'],
                        label: 'Wins',
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
                lawyer['bio'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B5B4E),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'Education',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EDE4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Colors.brown,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    lawyer['education'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3E2C23),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'Contact Information',
              child: Column(
                children: [
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: lawyer['phone'],
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: lawyer['email'],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookAppointmentScreen(lawyer: lawyer),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ViewAppointmentsScreen(lawyerId: lawyer['id']),
                        ),
                      );
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
  final String value;
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
          value,
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
