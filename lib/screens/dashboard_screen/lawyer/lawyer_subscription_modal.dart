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
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
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

      if (mounted) {
        Navigator.of(context).pop();
      }

      Get.snackbar(
        "Submitted Successfully",
        "Your payment proof has been submitted. Admin will review and activate your subscription.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      widget.onSuccess?.call();
    } catch (e) {
      Get.snackbar(
        "Submission Failed",
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
                const Text(
                  "Renew Subscription",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.Brown,
                  ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Monthly Fee",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.labelSecondary,
                        ),
                      ),
                      Text(
                        "PKR ${widget.fee}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.Brown,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    "Admin JazzCash Account:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.Brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _jazzCashAccountNumber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.Brown,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Title: $_jazzCashAccountTitle",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.labelSecondary,
                            ),
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
            const Text(
              "Transaction ID (TID)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.Brown,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _tidController,
              decoration: InputDecoration(
                hintText: "e.g. 02938472918",
                filled: true,
                fillColor: Colors.white,
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

            // Screenshot Upload
            const Text(
              "Payment Screenshot (Optional if TID provided)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.Brown,
              ),
            ),
            const SizedBox(height: 8),

            if (_screenshotBytes != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
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
                  _screenshotBytes == null ? "Upload Payment Screenshot" : "Change Screenshot",
                  style: const TextStyle(color: AppColors.Brown),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProof,
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
                        "Submit Proof for Verification",
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
    );
  }
}