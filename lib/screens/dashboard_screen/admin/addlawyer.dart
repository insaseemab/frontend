import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';
import 'package:get/get.dart';

final Color _primaryColor = AppColors.Brown;
final Color _bgColor = AppColors.beige;
final Color _borderColor = AppColors.divider;
final Color _hintColor = AppColors.hintText;

class AddLawyerPage extends StatefulWidget {
  const AddLawyerPage({super.key});

  @override
  State<AddLawyerPage> createState() => _AddLawyerPageState();
}

class _AddLawyerPageState extends State<AddLawyerPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final specializationController = TextEditingController();
  final cityController = TextEditingController();
  final experienceController = TextEditingController();
  final casesController = TextEditingController();

  bool isLoading = false;

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: _hintColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  Widget _themedField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String hint = '',
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: _inputDecor(hint.isEmpty ? 'Enter $label' : hint),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    specializationController.dispose();
    cityController.dispose();
    experienceController.dispose();
    casesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await LawyerService().createLawyer(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        specialization: specializationController.text,
        location: cityController.text,
        experience: experienceController.text,
        cases: casesController.text,
      );
      Get.back();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Lawyer',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Account Details'),
              const SizedBox(height: 10),

              _themedField(
                'Name',
                nameController,
                hint: 'Enter full name',
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              _themedField(
                'Email',
                emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'Enter email address',
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
              _themedField(
                'Password',
                passwordController,
                keyboardType: TextInputType.visiblePassword,
                hint: 'Enter password',
                validator: (v) => v!.isEmpty ? 'Enter password' : null,
              ),

              const SizedBox(height: 8),
              _sectionLabel('Professional Details'),
              const SizedBox(height: 10),

              _themedField(
                'Specialization',
                specializationController,
                hint: 'e.g. Family Law',
                validator: (v) => v!.isEmpty ? 'Enter specialization' : null,
              ),
              _themedField(
                'Location',
                cityController,
                hint: 'Enter city',
                validator: (v) => v!.isEmpty ? 'Enter location' : null,
              ),
              _themedField(
                'Experience (years)',
                experienceController,
                keyboardType: TextInputType.number,
                hint: 'Enter years of experience',
                validator: (v) => v!.isEmpty ? 'Enter experience' : null,
              ),
              _themedField(
                'Total Cases',
                casesController,
                keyboardType: TextInputType.number,
                hint: 'Enter total cases handled',
                validator: (v) => v!.isEmpty ? 'Enter cases' : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}