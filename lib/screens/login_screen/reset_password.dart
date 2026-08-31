import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/auth_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController.text = _extractTokenFromUrl();
  }

  String _extractTokenFromUrl() {
    final uri = Uri.base;

    // Case: normal query string (non-hash routing)
    if (uri.queryParameters.containsKey('token')) {
      return uri.queryParameters['token'] ?? '';
    }

    // Case: hash routing -> fragment looks like "/reset-password?token=xxxx"
    final fragment = uri.fragment;
    if (fragment.contains('?')) {
      final queryPart = fragment.split('?').last;
      final params = Uri.splitQueryString(queryPart);
      return params['token'] ?? '';
    }

    return '';
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty) {
      Get.snackbar(
        "Error",
        "Reset token is missing or invalid. Please use the link from your email again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.resetPassword(token, password, confirmPassword);
    setState(() => _isLoading = false);

    if (!result['success']) {
      Get.snackbar(
        "Error",
        result['message'] ?? "Failed to reset password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      "Success",
      result['message'] ?? "Password reset successfully",
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.offAllNamed(AppRoutes.login);
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
                    Icons.lock_outline,
                    color: AppColors.Brown,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                Text("Reset Password", style: AppTextStyles.heading1),

                const SizedBox(height: 6),

                Text(
                  "Paste the token from your email and\nset a new password",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _tokenController,
                  readOnly: true,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Reset token",
                    hintStyle: AppTextStyles.hint,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    prefixIcon: Icon(
                      Icons.vpn_key_outlined,
                      color: AppColors.iconMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "New password",
                    hintStyle: AppTextStyles.hint,
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.iconMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.iconMuted,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Confirm new password",
                    hintStyle: AppTextStyles.hint,
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.iconMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.iconMuted,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
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
                      : Text("Reset Password", style: AppTextStyles.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}