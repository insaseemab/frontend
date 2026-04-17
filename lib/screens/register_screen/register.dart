import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  
  bool isClient = true;

  
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  final barCouncilController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();


  final List<String> specializations = [
    'Civil Law',
    'Criminal Law',
    'Family Law',
    'Property Law',
    'Corporate Law',
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
    specializationController.dispose();
    experienceController.dispose();
    super.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
  
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isClient = true;
                          });
                        },
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
                        onTap: () {
                          setState(() {
                            isClient = false;
                          });
                        },
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
                                color: !isClient ? Colors.white : Colors.brown,
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

                if (isClient) ...[
                  buildTextField("Full Name", fullNameController),
                  const SizedBox(height: 12),
                  buildTextField("Email", emailController),
                  const SizedBox(height: 12),
                  buildTextField("Phone Number", phoneController),
                  const SizedBox(height: 12),
                  buildTextField("Password", passwordController, obscure: true),
                  const SizedBox(height: 12),
                  buildTextField("Confirm Password", confirmPasswordController, obscure: true),
                  const SizedBox(height: 20),
                  createAccountButton(),
                  const SizedBox(height: 12),
                  loginText()
                ] else ...[

                  buildTextField("Full Name", fullNameController),
                  const SizedBox(height: 12),
                  buildTextField("Email", emailController),
                  const SizedBox(height: 12),
                  buildTextField("Phone Number", phoneController),
                  const SizedBox(height: 12),
                  buildTextField("Bar Council ID", barCouncilController),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: selectedSpecialization,
                    items: specializations
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
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
                    onChanged: (val) {
                      setState(() {
                        selectedSpecialization = val;
                      });
                    },
                  ),

                  const SizedBox(height: 12),
                  buildTextField("Experience (years)", experienceController),
                  const SizedBox(height: 12),
                  buildTextField("Password", passwordController, obscure: true),
                  const SizedBox(height: 12),
                  buildTextField("Confirm Password", confirmPasswordController, obscure: true),
                  const SizedBox(height: 20),
                  createAccountButton(),
                  const SizedBox(height: 12),
                  loginText()
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget createAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4F3F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
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
          onTap: () {
            Get.back(); 
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}