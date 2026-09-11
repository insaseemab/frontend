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
    _initToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tokenController.text.isEmpty) {
        _initToken();
      }
    });
  }

  void _initToken() {
    final token = _extractTokenFromUrl();
    if (token.isNotEmpty && mounted) {
      setState(() {
        _tokenController.text = token;
      });
    }
  }

  String _extractTokenFromUrl() {
    // 1. Check GetX route parameters first
    if (Get.parameters.containsKey('token') && (Get.parameters['token'] ?? '').isNotEmpty) {
      return Get.parameters['token']!;
    }

    // 2. Check Get.arguments (if passed when navigating)
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['token'] != null) {
        return Get.arguments['token'].toString();
      } else if (Get.arguments is String && (Get.arguments as String).isNotEmpty) {
        return Get.arguments as String;
      }
    }

    // 3. Check Uri.base query parameters
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('token') && (uri.queryParameters['token'] ?? '').isNotEmpty) {
      return uri.queryParameters['token']!;
    }

    // 4. Check uri.fragment (e.g. #/reset-password?token=xxxx)
    final fragment = uri.fragment;
    if (fragment.contains('token=')) {
      final queryPart = fragment.contains('?') ? fragment.split('?').last : fragment;
      final params = Uri.splitQueryString(queryPart);
      if (params.containsKey('token') && (params['token'] ?? '').isNotEmpty) {
        return params['token']!;
      }
    }

    // 5. Fallback: regex search on complete URL string
    final fullUrl = uri.toString();
    final regExp = RegExp(r'[?&#]token=([^&#]+)');
    final match = regExp.firstMatch(fullUrl);
    if (match != null && match.groupCount >= 1) {
      return Uri.decodeComponent(match.group(1)!);
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
        "Reset token is missing. Please paste the token from your email link.",
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
                  "Enter your reset token and\nset a new password",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _tokenController,
                  readOnly: false,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Reset token (auto-filled or paste here)",
                    hintStyle: AppTextStyles.hint,
                    filled: true,
                    fillColor: AppColors.white,
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