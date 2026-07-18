import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/auth_services.dart';
import 'package:insaafconnect/routes/app_routes.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool isClient = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final barCouncilController = TextEditingController();
  final experienceController = TextEditingController();
  final categoryController = TextEditingController();
  Uint8List? licenseImageBytes;
  String? licenseImageName;
  final ImagePicker _picker = ImagePicker();

  final List<String> specializations = [
    'Civil Law',
    'Session Court',
    'High Court',
    'Supreme Court',
  ];

  String? selectedSpecialization;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    barCouncilController.dispose();
    experienceController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  // ── Field-level validators ────────────────────────────
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return "Full name is required";
    if (value.trim().length < 3) return "Name must be at least 3 characters";
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim()))
      return "Enter a valid email address";
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Phone number is required";
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter a valid phone number (digits only)";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Please confirm your password";
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

  String? _validateBarCouncil(String? value) {
    if (!isClient && (value == null || value.trim().isEmpty)) {
      return "Bar Council ID is required";
    }
    return null;
  }

  String? _validateExperience(String? value) {
    if (!isClient) {
      if (value == null || value.trim().isEmpty)
        return "Experience is required";
      final years = int.tryParse(value.trim());
      if (years == null || years < 0) return "Enter a valid number of years";
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (!isClient && (value == null || value.trim().isEmpty)) {
      return "Category is required";
    }
    return null;
  }

  String? _validateLicense() {
    if (!isClient && licenseImageBytes == null) {
      return "License picture is required";
    }
    return null;
  }

  // ── Register Handler ──────────────────────────────────
  Future<void> _handleRegister() async {
    // 1. Run all field validators
    final isValid = _formKey.currentState?.validate() ?? false;

    // 2. Dropdown validator runs separately since it isn't a TextFormField
    if (!isClient && selectedSpecialization == null) {
      Get.snackbar(
        "Validation Error",
        "Please select a specialization",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 3. License validator runs separately since it's an image, not a form field
    final licenseError = _validateLicense();
    if (licenseError != null) {
      Get.snackbar(
        "Validation Error",
        licenseError,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    // 4. Build body based on role
    final Map<String, dynamic> body = {
      'name': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'password': passwordController.text,
      'role': isClient ? 'client' : 'lawyer',
    };

    if (!isClient) {
      body['bar_council_id'] = barCouncilController.text.trim();
      body['specialization'] = selectedSpecialization;
      body['category'] = categoryController.text.trim();
      body['experience'] = experienceController.text.trim();
    }

    // 5. Call API (with license image attached for lawyers)
    final result = await AuthService.register(
  body,
  licenseImageBytes: licenseImageBytes,
  licenseImageName: licenseImageName,
);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Get.snackbar(
        "Success",
        "Account created!",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );

      // ── Navigate based on role ──────────────────────────
      if (isClient) {
        Get.offAllNamed(AppRoutes.clientDashboard);
      } else {
        Get.offAllNamed(AppRoutes.lawyerDashboard);
      }
    } else {
      Get.snackbar(
        "Error",
        result['message'] ?? "Registration failed. Please try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickLicenseImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // works on web + mobile
      setState(() {
        licenseImageBytes = bytes;
        licenseImageName = pickedFile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2EE),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Logo ─────────────────────────────────
                  Container(
                    height: 90,
                    width: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6DED3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // ── Client / Lawyer Toggle ────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isClient = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isClient
                                  ? const Color(0xFF6B4F3F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.brown),
                            ),
                            child: Center(
                              child: Text(
                                "Register as Client",
                                style: TextStyle(
                                  color: isClient ? Colors.white : Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isClient = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isClient
                                  ? const Color(0xFF6B4F3F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.brown),
                            ),
                            child: Center(
                              child: Text(
                                "Register as Lawyer",
                                style: TextStyle(
                                  color: !isClient
                                      ? Colors.white
                                      : Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Common Fields ─────────────────────────
                  buildTextField(
                    "Full Name",
                    fullNameController,
                    validator: _validateFullName,
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    "Email",
                    emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    "Phone Number",
                    phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 12),

                  // ── Lawyer-only Fields ────────────────────
                  if (!isClient) ...[
                    buildTextField(
                      "Bar Council ID",
                      barCouncilController,
                      validator: _validateBarCouncil,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedSpecialization,
                      items: specializations
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        hintText: "Specialization",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => selectedSpecialization = val),
                    ),
                    const SizedBox(height: 12),

                    buildTextField(
                      "Category (e.g. Corporate, Criminal, Family)",
                      categoryController,
                      validator: _validateCategory,
                    ),
                    const SizedBox(height: 12),

                    buildTextField(
                      "Experience (years)",
                      experienceController,
                      keyboardType: TextInputType.number,
                      validator: _validateExperience,
                    ),
                    const SizedBox(height: 12),

                    // ── License Upload ────────────────────
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Upload License Picture",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickLicenseImage,
                      child: Container(
                        width: double.infinity,
                        height: licenseImageBytes!= null ? 160 : 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: licenseImageBytes == null
                                ? Colors.brown.shade200
                                : Colors.brown,
                          ),
                        ),
                        child: licenseImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  licenseImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      color: Colors.brown,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Tap to upload license picture",
                                      style: TextStyle(
                                        color: Colors.brown,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Password Fields ───────────────────────
                  buildTextField(
                    "Password",
                    passwordController,
                    obscure: _obscurePassword,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    "Confirm Password",
                    confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Submit Button ─────────────────────────
                  createAccountButton(),
                  const SizedBox(height: 12),
                  loginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget createAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4F3F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget loginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Get.back(),
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
