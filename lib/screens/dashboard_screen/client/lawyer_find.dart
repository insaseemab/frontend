import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/message_services.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import '../../appointments/appointment_screen.dart';
import 'package:insaafconnect/routes/app_routes.dart';
import 'package:insaafconnect/core/utils/theme.dart'; 

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
      final spec = (lawyer['specialization'] ?? '').toString().toLowerCase();

      // "Criminal Law" -> "criminal", "Civil Law" -> "civil", etc.
      final filterKeyword = selectedFilter
          .toLowerCase()
          .replaceAll(' law', '')
          .trim();

      final matchFilter =
          selectedFilter == 'All' || spec.contains(filterKeyword);

      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          (lawyer['name'] ?? '').toString().toLowerCase().contains(q) ||
          spec.contains(q) ||
          (lawyer['location'] ?? '').toString().toLowerCase().contains(q);

      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find a Lawyer',
              style: AppTextStyles.heading3,
            ),
            Text(
              'Search for legal professionals',
              style: AppTextStyles.bodySmall,
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
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.hintText,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.Brown, width: 1.5),
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
                  Icon(
                    Icons.filter_list,
                    color: AppColors.iconMuted,
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
                                ? AppColors.Brown
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.Brown
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.labelSecondary,
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
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.Brown),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadLawyers,
                          child: Text(
                            'Retry',
                            style: TextStyle(color: AppColors.Brown),
                          ),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Text(
                      'No lawyers found for this filter.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220, // max width per card
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent:
                                  340, // fixed card height that fits content comfortably
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _LawyerCard(lawyer: filtered[i]),
                      );
                    },
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

bool _isApproved(Map<String, dynamic> lawyer) {
  final status = lawyer['status'];
  if (status == null) return true; // endpoint already filters approved-only
  if (status is bool) return status;
  if (status is int) return status == 1;
  return status.toString() == '1' ||
      status.toString().toLowerCase() == 'approved';
}

class _LawyerCard extends StatelessWidget {
  final Map<String, dynamic> lawyer;
  const _LawyerCard({required this.lawyer});

  Future<void> _openChat() async {
  final result = await MessageService().startConversation(
    lawyerId: lawyer['id'],
  );
  if (result != null) {
    Get.toNamed(
      AppRoutes.message,
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
      decoration: AppDecorations.card,
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
                  backgroundColor: AppColors.Brown,
                  child: Text(
                    (lawyer['name'] ?? 'L').toString()[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
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
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 13,
                        color: AppColors.earningsOrange,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (lawyer['rating'] ?? '0.0').toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.Brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _isApproved(lawyer)
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 13,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            Text(
              (lawyer['name'] ?? 'Unknown').toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.Brown,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              (lawyer['specialization'] ?? '').toString(),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.iconMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  (lawyer['location'] ?? '-').toString(),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (lawyer['experience'] ?? '-').toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.hintText,
                  ),
                ),
                Text(
                  (lawyer['cases'] ?? '-').toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.hintText,
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
                  backgroundColor: AppColors.Brown,
                  foregroundColor: AppColors.white,
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
                  foregroundColor: AppColors.Brown,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  side: BorderSide(color: AppColors.cardBorder),
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
        AppRoutes.message,
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
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.Brown,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Lawyer Profile',
          style: AppTextStyles.heading3,
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
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.Brown,
                    child: Text(
                      (lawyer['name'] ?? 'L')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (lawyer['name'] ?? 'Unknown Lawyer').toString(),
                        style: AppTextStyles.heading2,
                      ),
                      if (_isApproved(lawyer)) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    (lawyer['specialization'] ?? 'Not Available').toString(),
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.iconMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (lawyer['location'] ?? 'Not Available').toString(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(
                        icon: Icons.star,
                        iconColor: AppColors.earningsOrange,
                        value: (lawyer['rating'] ?? '0.0').toString(),
                        label: 'Rating',
                      ),

                      _divider(),

                      _StatBox(
                        icon: Icons.work_outline,
                        iconColor: AppColors.Brown,
                        value: (lawyer['experience'] ?? '0').toString(),
                        label: 'Experience',
                      ),

                      _divider(),

                      _StatBox(
                        icon: Icons.gavel,
                        iconColor: AppColors.Brown,
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
                style: AppTextStyles.bodyLarge,
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
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cases: ${(lawyer['cases'] ?? 'Not Available')}',
                    style: AppTextStyles.bodyMedium,
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
                      backgroundColor: AppColors.Brown,
                      foregroundColor: AppColors.white,
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
                      foregroundColor: AppColors.Brown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.Brown,
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
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppColors.divider);
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
          style: AppTextStyles.heading4,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
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
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4,
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
            color: AppColors.beige,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.Brown, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyLarge,
        ),
      ],
    );
  }
}