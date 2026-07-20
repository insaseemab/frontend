import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/appointment_services.dart';
import 'package:get/get.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Map appointment;

  const PaymentBottomSheet({super.key, required this.appointment});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String selectedMethod = "Cash";
  Uint8List? screenshotBytes;
  String? screenshotName;
  bool _isSubmitting = false;

  final _cardFormController = CardFormEditController();

  @override
  void dispose() {
    _cardFormController.dispose();
    super.dispose();
  }

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
      if (selectedMethod == "Card") {
        await _submitStripePayment();
      } else {
        await AppointmentService.payAppointment(
          widget.appointment['id'],
          selectedMethod,
          screenshotBytes,
        );
      }

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

  Future<void> _submitStripePayment() async {
    if (!_cardFormController.details.complete) {
      throw "Please complete the card details";
    }

    
    final clientSecret = await AppointmentService.createStripePaymentIntent(
      widget.appointment['id'],
      widget.appointment['payment_amount'],
    );


    final paymentIntent = await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );

    if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
      throw "Payment was not completed";
    }

    
    await AppointmentService.confirmAppointmentPayment(
      widget.appointment['id'],
      paymentIntent.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Payment Method",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Consultation Fee"),
                Text(
                  "PKR ${widget.appointment['payment_amount']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF5C3D2E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMethod = "Cash";
                    });
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedMethod == "Cash"
                          ? const Color(0xFF5C3D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload,
                          color: selectedMethod == "Cash"
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Cash Payment",
                          style: TextStyle(
                            color: selectedMethod == "Cash"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMethod = "Card";
                    });
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedMethod == "Card"
                          ? const Color(0xFF5C3D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          color: selectedMethod == "Card"
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Card",
                          style: TextStyle(
                            color: selectedMethod == "Card"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (selectedMethod == "Cash")
            Column(
              children: [
                OutlinedButton(
                  onPressed: pickImage,
                  child: const Text("Upload Screenshot"),
                ),
                if (screenshotName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(screenshotName!),
                  ),
              ],
            ),

          if (selectedMethod == "Stripe")
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CardFormField(
                controller: _cardFormController,
                style: CardFormStyle(
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderRadius: 15,
                ),
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
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
                      "Submit Payment",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}