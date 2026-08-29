import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/rating_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class RatingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const RatingBottomSheet({super.key, required this.appointment});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _rating = 0;
  final TextEditingController _reviewCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_rating == 0) {
      Get.snackbar('Error', 'Please select a rating', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final appointmentId = widget.appointment['id'] as int;
      final lawyerId = widget.appointment['lawyer_id'] as int;

      await RatingService.submitRating(
        appointmentId,
        lawyerId,
        _rating,
        _reviewCtrl.text.trim(),
      );

      if (!mounted) return;
      Get.back(); // close sheet
      Get.snackbar('Success', 'Rating submitted successfully!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate Lawyer',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.earningsOrange,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave an optional review...',
                hintStyle: AppTextStyles.hint,
                filled: true,
                fillColor: AppColors.beige,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.Brown, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Brown,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                      )
                    : const Text('Submit Rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}