import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class LawyerSubscriptionModal extends StatefulWidget {
  final String fee;
  final VoidCallback? onSuccess;

  const LawyerSubscriptionModal({
    super.key,
    required this.fee,
    this.onSuccess,
  });

  @override
  State<LawyerSubscriptionModal> createState() => _LawyerSubscriptionModalState();
}

class _LawyerSubscriptionModalState extends State<LawyerSubscriptionModal> {
  final _tidController = TextEditingController();
  final LawyerService _lawyerService = LawyerService();

  Uint8List? _screenshotBytes;
  String? _screenshotName;
  bool _isSubmitting = false;

  final String _jazzCashAccountTitle = "Admin Insaaf";
  final String _jazzCashAccountNumber = "0300-1234567";

  @override
  void dispose() {
    _tidController.dispose();
    super.dispose();
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
        "Image Picker Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> _submitProof() async {
    final tid = _tidController.text.trim();
    if (tid.isEmpty && _screenshotBytes == null) {
      Get.snackbar(
        "Required",
        "Please enter your JazzCash TID or upload a receipt screenshot.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.white,
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

      if (mounted) {
        Navigator.of(context).pop();
      }

      Get.snackbar(
        "Submitted Successfully",
        "Your payment proof has been submitted. Admin will review and activate your subscription.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );

      widget.onSuccess?.call();
    } catch (e) {
      Get.snackbar(
        "Submission Failed",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Renew Subscription",
                  style: AppTextStyles.heading2.copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.Brown),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Account details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Monthly Fee", style: AppTextStyles.labelMuted),
                      Text(
                        "PKR ${widget.fee}",
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text("Admin JazzCash Account:", style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _jazzCashAccountNumber,
                            style: AppTextStyles.heading3.copyWith(letterSpacing: 0.5),
                          ),
                          Text(
                            "Title: $_jazzCashAccountTitle",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: AppColors.Brown),
                        tooltip: "Copy Account Number",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _jazzCashAccountNumber));
                          Get.snackbar(
                            "Copied",
                            "JazzCash number copied to clipboard",
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Transaction ID input
            Text("Transaction ID (TID)", style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _tidController,
              decoration: const InputDecoration(
                hintText: "e.g. 02938472918",
              ),
            ),

            const SizedBox(height: 16),

            // Screenshot Upload
            Text(
              "Payment Screenshot (Optional if TID provided)",
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),

            if (_screenshotBytes != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _screenshotBytes!,
                        width: 50,
                        height: 50,
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
                  _screenshotBytes == null ? "Upload Payment Screenshot" : "Change Screenshot",
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.Brown),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProof,
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
                      "Submit Proof for Verification",
                      style: AppTextStyles.button,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}