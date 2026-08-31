import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/auth_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'reset_password.dart';
import '../../routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Email is required");
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.forgotPassword(email);
    setState(() => _isLoading = false);

    if (!result['success']) {
      Get.snackbar(
        "Error",
        result['message'] ?? "Failed to send reset link",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      "Check your email",
      result['message'] ?? "Password reset link sent",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );

    Get.toNamed(AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardFill,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.Brown.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.navActive,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.lock_reset,
                    color: AppColors.Brown,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                Text("Forgot Password?", style: AppTextStyles.heading1),

                const SizedBox(height: 6),

                Text(
                  "Enter your email to receive a reset link",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "your.email@example.com",
                    hintStyle: AppTextStyles.hint,
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.iconMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: AppButtonStyles.primary,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text("Send Reset Link", style: AppTextStyles.button),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Back to Login",
                    style: AppTextStyles.label.copyWith(color: AppColors.Brown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}