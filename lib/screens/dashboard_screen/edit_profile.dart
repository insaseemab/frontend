import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/core/services/api_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class EditLawyerProfile extends StatefulWidget {
  const EditLawyerProfile({super.key});

  @override
  State<EditLawyerProfile> createState() => _EditLawyerProfileState();
}

class _EditLawyerProfileState extends State<EditLawyerProfile> {
  final box = GetStorage();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController specializationCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController passwordCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Map<String, dynamic>.from(box.read('user') ?? {});
    nameCtrl = TextEditingController(text: user['name']?.toString() ?? '');
    emailCtrl = TextEditingController(text: user['email']?.toString() ?? '');
    phoneCtrl = TextEditingController(text: user['phone']?.toString() ?? '');
    locationCtrl = TextEditingController(text: user['location']?.toString() ?? '');
    specializationCtrl = TextEditingController(text: user['specialization']?.toString() ?? '');
    experienceCtrl = TextEditingController(text: user['experience']?.toString() ?? '');
    passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    specializationCtrl.dispose();
    experienceCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'specialization': specializationCtrl.text.trim(),
        'experience': experienceCtrl.text.trim(),
      };
      
      if (passwordCtrl.text.isNotEmpty) {
        data['password'] = passwordCtrl.text;
      }

      await ApiService.updateLawyerProfile(data);

      // Update local storage
      final user = Map<String, dynamic>.from(box.read('user') ?? {});
      user['name'] = data['name'];
      user['email'] = data['email'];
      user['phone'] = data['phone'];
      user['location'] = data['location'];
      user['specialization'] = data['specialization'];
      user['experience'] = data['experience'];
      box.write('user', user);

      Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.Brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.Brown),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Full Name', nameCtrl),
              const SizedBox(height: 16),
              _buildField('Email Address', emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Phone Number', phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField('Location', locationCtrl),
              const SizedBox(height: 16),
              _buildField('Specialization', specializationCtrl),
              const SizedBox(height: 16),
              _buildField('Experience (Years)', experienceCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField('New Password (leave blank to keep current)', passwordCtrl, obscureText: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.Brown, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF5EFE6),
      ),
      validator: (value) {
        if (label != 'New Password (leave blank to keep current)' && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}