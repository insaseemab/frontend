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
  final String _jazzCashAccountNumber = "0300-1234567";

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
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
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
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
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
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      _loadData();
    } catch (e) {
      Get.snackbar(
        "Submission Error",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.Brown),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Subscription & Billing",
          style: TextStyle(
            color: AppColors.Brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.Brown))
          : RefreshIndicator(
              color: AppColors.Brown,
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
                        color: isExpired ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isExpired ? Colors.red.shade300 : Colors.green.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpired ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                            size: 36,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isExpired ? "Subscription Expired" : "Subscription Active",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isExpired ? Colors.red.shade900 : Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isExpired
                                      ? "Your account is hidden from client search. Renew to start getting appointments."
                                      : "Valid until ${subDateStr.toString().split('T')[0]}. Visible to clients.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isExpired ? Colors.red.shade800 : Colors.green.shade800,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.Brown.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monthly Subscription",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.labelSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.Brown.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "PKR $fee / Month",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.Brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text(
                            "Step 1: Transfer via JazzCash",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.Brown,
                            ),
                          ),
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
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: AppColors.Brown,
                                        ),
                                      ),
                                      Text(
                                        "Account Title: $_jazzCashAccountTitle",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.labelSecondary,
                                        ),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.Brown.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 2: Submit Payment Details",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.Brown,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // TID Field
                          const Text(
                            "Transaction ID (TID / Trx ID)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.Brown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _tidController,
                            decoration: InputDecoration(
                              hintText: "e.g. 02847291048",
                              filled: true,
                              fillColor: AppColors.beige.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

                          const SizedBox(height: 16),

                          // Screenshot upload
                          const Text(
                            "Payment Receipt / Screenshot",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.Brown,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (_screenshotBytes != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.Brown,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                                style: const TextStyle(color: AppColors.Brown),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.Brown,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Submit Payment for Review",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
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