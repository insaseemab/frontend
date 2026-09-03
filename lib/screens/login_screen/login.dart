import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/auth_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:insaafconnect/screens/login_screen/forgot_password.dart';
import '../register_screen/register.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final box = GetStorage();

  Future<void> login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!result['success']) {
      final errorMessage =
          result['message'] ?? 'Login failed. Please try again.';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final user = result['data']['user'] as Map<String, dynamic>;
    final role = user['role'].toString().toLowerCase();

    if (role != 'admin' && role != 'lawyer' && role != 'client') {
      Get.snackbar('Access Denied', 'Your role is not recognized.');
      return;
    }

    final token = result['token'];
    final userId = user['id'];
    final userName = user['name'];

    box.write('user', user);
    box.write('id', userId);
    box.write('userId', userId);
    box.write('userName', userName);
    box.write('token', token);
    box.write('role', role);
    box.write('isLoggedIn', true);

    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'lawyer':
        Get.offAllNamed(AppRoutes.lawyerDashboard);
        break;
      case 'client':
        Get.offAllNamed(AppRoutes.clientDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Logo icon
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.navActive,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height:20),

                // Role pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.overlayLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                Text("Welcome Back", style: AppTextStyles.heading1),

                const SizedBox(height: 6),

                Text(
                  "Enter your credentials to continue",
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 28),

                // Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardFill,
                    borderRadius: BorderRadius.circular(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email Address", style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: "your.email@example.com",
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: AppColors.iconMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text("Password", style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.iconMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.iconMuted,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Remember me + Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.Brown,
                                  onChanged: (val) {
                                    setState(() => _rememberMe = val ?? false);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text("Remember me", style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/forgot-password');
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.Brown,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _isLoading ? null : login,
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
                            : Text("Login", style: AppTextStyles.button),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const RegisterPage());
                              },
                              child: Text(
                                "Register",
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.Brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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