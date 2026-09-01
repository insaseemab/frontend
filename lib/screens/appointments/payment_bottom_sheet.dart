import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/appointment_services.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/utils/theme.dart';

enum _PaymentMethod { screenshot, cash }

class PaymentBottomSheet extends StatefulWidget {
  final Map appointment;

  const PaymentBottomSheet({super.key, required this.appointment});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  Uint8List? screenshotBytes;
  String? screenshotName;
  bool _isSubmitting = false;
  _PaymentMethod _selectedMethod = _PaymentMethod.screenshot;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 60,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        screenshotBytes = bytes;
        screenshotName = picked.name;
      });
    }
  }

  Future submitPayment() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await AppointmentService.payAppointment(
        widget.appointment['id'],
        _selectedMethod == _PaymentMethod.cash ? "Cash" : "Manual",
        _selectedMethod == _PaymentMethod.cash ? null : screenshotBytes,
      );

      Get.back();

      Get.snackbar(
        "Success",
        "Payment submitted successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _methodOption({
    required _PaymentMethod method,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.Brown.withOpacity(0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.Brown : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.Brown : AppColors.labelSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.Brown : AppColors.labelSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Payment Method",
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Consultation Fee"),
                Text(
                  "PKR ${widget.appointment['payment_amount']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.Brown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Payment method selector ──
          Row(
            children: [
              _methodOption(
                method: _PaymentMethod.screenshot,
                icon: Icons.upload_file,
                label: "Pay Online",
              ),
              const SizedBox(width: 12),
              _methodOption(
                method: _PaymentMethod.cash,
                icon: Icons.payments_outlined,
                label: "Pay in Cash",
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (_selectedMethod == _PaymentMethod.screenshot)
            Column(
              children: [
                OutlinedButton(
                  onPressed: pickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.Brown,
                    side: BorderSide(color: AppColors.cardBorder),
                  ),
                  child: const Text("Upload Screenshot"),
                ),

                if (screenshotName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      screenshotName!,
                      style: TextStyle(color: AppColors.labelSecondary),
                    ),
                  ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.labelSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You'll pay the lawyer directly in cash. Tap submit to confirm.",
                      style: TextStyle(color: AppColors.labelSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.Brown,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Submit Payment",
                      style: TextStyle(color: AppColors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}