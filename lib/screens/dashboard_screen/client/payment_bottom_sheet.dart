import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/appointment_services.dart';
import 'package:get/get.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Map appointment;

  const PaymentBottomSheet({super.key, required this.appointment});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String selectedMethod = "Manual";

  File? screenshot;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        screenshot = File(picked.path);
      });
    }
  }

 Future submitPayment() async {
  try {
    await ApiService.payAppointment(
      widget.appointment['id'],
      selectedMethod,
      screenshot,
    );

    Get.back();

    Get.snackbar(
      "Success",
      "Payment submitted successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    print(e);

    Get.snackbar(
      "Error",
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
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
          Text(
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
                      selectedMethod = "Manual";
                    });
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedMethod == "Manual"
                          ? const Color(0xFF5C3D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload,
                          color: selectedMethod == "Manual"
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Manual Payment",
                          style: TextStyle(
                            color: selectedMethod == "Manual"
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
                      selectedMethod = "Stripe";
                    });
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedMethod == "Stripe"
                          ? const Color(0xFF5C3D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          color: selectedMethod == "Stripe"
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Stripe",
                          style: TextStyle(
                            color: selectedMethod == "Stripe"
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

          if (selectedMethod == "Manual")
            Column(
              children: [
                OutlinedButton(
                  onPressed: pickImage,
                  child: const Text("Upload Screenshot"),
                ),

                if (screenshot != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(screenshot!.path.split('/').last),
                  ),
              ],
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
              ),
              child: const Text("Submit Payment"),
            ),
          ),
        ],
      ),
    );
  }
}
