import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class LawyerLicensesScreen extends StatefulWidget {
  const LawyerLicensesScreen({super.key});

  @override
  State<LawyerLicensesScreen> createState() => _LawyerLicensesScreenState();
}

class _LawyerLicensesScreenState extends State<LawyerLicensesScreen> {
  final _service = LawyerService();
  List<Map<String, dynamic>> _lawyers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchLawyerLicenses();
      setState(() => _lawyers = data);
    } catch (e) {
      setState(() => _error = 'Failed to load lawyer licenses: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openLicense(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      Get.snackbar('Error', 'Could not open license file');
    }
  }

  void _showFullImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(
            url,
            errorBuilder: (_, __, ___) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load image',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _specializationLine(Map<String, dynamic> lawyer) {
    final specialization = (lawyer['specialization'] ?? '').toString().trim();
    final category = (lawyer['category'] ?? '').toString().trim();
    if (specialization.isEmpty && category.isEmpty) return '';
    if (specialization.isEmpty) return category;
    if (category.isEmpty) return specialization;
    return '$specialization • $category';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("Lawyer Licenses", style: AppTextStyles.heading3),
        backgroundColor: AppColors.beige,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.Brown,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.Brown))
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text(_error!, style: AppTextStyles.bodyMedium)),
                ],
              )
            : _lawyers.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 150),
                  Center(child: Text("No lawyers found", style: AppTextStyles.bodyMedium)),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _lawyers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lawyer = _lawyers[index];
                  final licenseUrl = LawyerService.buildLicenseUrl(
                    lawyer['license'],
                  );
                  final isImg =
                      licenseUrl != null &&
                      LawyerService.isImageLicense(licenseUrl);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lawyer['name'] ?? '',
                                style: AppTextStyles.heading4.copyWith(fontSize: 16),
                              ),
                            ),
                            _StatusChip(status: lawyer['status']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(lawyer['email'] ?? '', style: AppTextStyles.bodySmall),
                        if (_specializationLine(lawyer).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _specializationLine(lawyer),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (licenseUrl == null)
                          Text(
                            'No license uploaded',
                            style: TextStyle(
                              color: AppColors.error,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (isImg)
                          InkWell(
                            onTap: () => _showFullImage(licenseUrl),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                minHeight: 100,
                                maxHeight: 220,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.beige,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  licenseUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      height: 140,
                                      child: Center(
                                        child: CircularProgressIndicator(color: AppColors.Brown),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Center(
                                    child: SizedBox(
                                      height: 140,
                                      child: Center(
                                        child: Text(
                                          'Could not load license image',
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () => _openLicense(licenseUrl),
                            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.Brown),
                            label: Text('Open License', style: AppTextStyles.label),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.Brown),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final dynamic status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final raw = (status ?? '').toString().trim().toLowerCase();
    final isApproved = raw == '1' || raw == 'approved' || raw == 'active';
    final isRejected = raw == 'rejected' || raw == '2';

    final color = isApproved
        ? AppColors.success
        : isRejected
        ? AppColors.error
        : AppColors.warning;

    final label = isApproved
        ? 'Approved'
        : isRejected
        ? 'Rejected'
        : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}