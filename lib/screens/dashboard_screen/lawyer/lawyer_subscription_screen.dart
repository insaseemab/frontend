import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/services/settings_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class LawyerSubscriptionScreen extends StatefulWidget {
  const LawyerSubscriptionScreen({super.key});

  @override
  State<LawyerSubscriptionScreen> createState() => _LawyerSubscriptionScreenState();
}

class _LawyerSubscriptionScreenState extends State<LawyerSubscriptionScreen> {
  final box = GetStorage();
  final LawyerService _lawyerService = LawyerService();
  final _tidController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _lawyerData;
  Map<String, dynamic>? _settingsData;

  Uint8List? _screenshotBytes;
  String? _screenshotName;

  final String _jazzCashAccountTitle = "Admin Insaaf";
  final String _jazzCashAccountNumber = "0322 4405251";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tidController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = Map<String, dynamic>.from(box.read('user') ?? {});
      final rawId = box.read('id') ?? box.read('userId') ?? user['id'];
      final userId = int.tryParse(rawId?.toString() ?? '') ?? -1;

      if (userId > 0) {
        try {
          _lawyerData = await _lawyerService.fetchLawyerById(userId);
        } catch (e) {
          debugPrint("Error loading lawyer: $e");
        }
      }

      try {
        _settingsData = await SettingsService.getSettings();
      } catch (e) {
        debugPrint("Error loading settings: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 65,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _screenshotBytes = bytes;
          _screenshotName = picked.name;
        });
      }
    } catch (e) {
      Get.snackbar(
        "Picker Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.10),
        colorText: AppColors.error,
      );
    }
  }

  Future<void> _submitPayment() async {
    final tid = _tidController.text.trim();
    if (tid.isEmpty && _screenshotBytes == null) {
      Get.snackbar(
        "Required",
        "Please enter your Transaction ID (TID) or upload a receipt screenshot.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.10),
        colorText: AppColors.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? base64Img;
      if (_screenshotBytes != null) {
        base64Img = base64Encode(_screenshotBytes!);
      }

      await _lawyerService.submitSubscriptionPayment(
        transactionId: tid.isNotEmpty ? tid : null,
        paymentReceiptBase64: base64Img,
        paymentMethod: 'JazzCash',
      );

      _tidController.clear();
      setState(() {
        _screenshotBytes = null;
        _screenshotName = null;
      });

      Get.snackbar(
        "Proof Submitted",
        "Your payment proof has been submitted to Admin for review. Your subscription will be renewed once verified.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.10),
        colorText: AppColors.success,
        duration: const Duration(seconds: 4),
      );

      _loadData();
    } catch (e) {
      Get.snackbar(
        "Submission Error",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.10),
        colorText: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = _settingsData?['subscription_fee']?.toString() ?? '2000';
    final subDateStr = _lawyerData?['subscription_expiry'];
    DateTime? subDate;
    if (subDateStr != null) {
      subDate = DateTime.tryParse(subDateStr.toString());
    }
    final isExpired = subDate == null || subDate.isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
      backgroundColor: AppColors.beige,
        title: Text("Subscription & Billing", style: AppTextStyles.heading3.copyWith(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? AppColors.error.withOpacity(0.06)
                            : AppColors.success.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isExpired
                              ? AppColors.error.withOpacity(0.4)
                              : AppColors.success.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpired ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: isExpired ? AppColors.error : AppColors.success,
                            size: 36,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isExpired ? "Subscription Expired" : "Subscription Active",
                                  style: AppTextStyles.heading4.copyWith(
                                    fontSize: 17,
                                    color: isExpired ? AppColors.error : AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isExpired
                                      ? "Your account is hidden from client search. Renew to start getting appointments."
                                      : "Valid until ${subDateStr.toString().split('T')[0]}. Visible to clients.",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isExpired ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Admin JazzCash Payment Details
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppDecorations.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Monthly Subscription", style: AppTextStyles.labelMuted),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: AppDecorations.pill,
                                child: Text(
                                  "PKR $fee / Month",
                                  style: AppTextStyles.label.copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text("Step 1: Transfer via JazzCash", style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.beige.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_android, color: AppColors.Brown),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _jazzCashAccountNumber,
                                        style: AppTextStyles.heading3.copyWith(letterSpacing: 0.5),
                                      ),
                                      Text(
                                        "Account Title: $_jazzCashAccountTitle",
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: AppColors.Brown),
                                  tooltip: "Copy Number",
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _jazzCashAccountNumber));
                                    Get.snackbar(
                                      "Copied",
                                      "JazzCash account number copied",
                                      backgroundColor: AppColors.success.withOpacity(0.10),
                                      colorText: AppColors.success,
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Submission Form
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppDecorations.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Step 2: Submit Payment Details", style: AppTextStyles.label),
                          const SizedBox(height: 14),

                          // TID Field
                          Text("Transaction ID (TID / Trx ID)", style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _tidController,
                            decoration: const InputDecoration(
                              hintText: "e.g. 02847291048",
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Screenshot upload
                          Text("Payment Receipt / Screenshot", style: AppTextStyles.label),
                          const SizedBox(height: 8),

                          if (_screenshotBytes != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _screenshotBytes!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _screenshotName ?? "Receipt Screenshot",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () => setState(() {
                                      _screenshotBytes = null;
                                      _screenshotName = null;
                                    }),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file, color: AppColors.Brown),
                              label: Text(
                                _screenshotBytes == null
                                    ? "Upload Receipt Screenshot"
                                    : "Change Screenshot",
                                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.Brown),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitPayment,
                            style: AppButtonStyles.primary,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Submit Payment for Review",
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}