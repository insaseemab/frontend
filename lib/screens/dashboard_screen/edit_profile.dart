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
  late TextEditingController currentPasswordCtrl;
  late TextEditingController passwordCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Map<String, dynamic>.from(box.read('user') ?? {});
    nameCtrl = TextEditingController(text: user['name']?.toString() ?? '');
    emailCtrl = TextEditingController(text: user['email']?.toString() ?? '');
    phoneCtrl = TextEditingController(text: user['phone']?.toString() ?? '');
    locationCtrl = TextEditingController(
      text: user['location']?.toString() ?? '',
    );
    specializationCtrl = TextEditingController(
      text: user['specialization']?.toString() ?? '',
    );
    experienceCtrl = TextEditingController(
      text: user['experience']?.toString() ?? '',
    );
    currentPasswordCtrl = TextEditingController();
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
    currentPasswordCtrl.dispose();
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

      final rawId =
          box.read('userId') ?? box.read('id') ?? box.read('user')?['id'];
      final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

      await ApiService.updateProfile(id: id, data: data);

      // Password change goes through a separate, verified endpoint —
      // only fires if the user actually filled in a new password.
      if (passwordCtrl.text.isNotEmpty) {
        if (currentPasswordCtrl.text.isEmpty) {
          Get.snackbar(
            'Error',
            'Enter your current password to set a new one',
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() => _isLoading = false);
          return;
        }
        await ApiService.changePassword(
          id: id,
          currentPassword: currentPasswordCtrl.text,
          newPassword: passwordCtrl.text,
        );
      }

      // Update local storage
      final user = Map<String, dynamic>.from(box.read('user') ?? {});
      user['name'] = data['name'];
      user['email'] = data['email'];
      user['phone'] = data['phone'];
      user['location'] = data['location'];
      user['specialization'] = data['specialization'];
      user['experience'] = data['experience'];
      box.write('user', user);

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Header (matches the Profile screen's header style) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.Brown),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Profile', style: AppTextStyles.heading2),
                        Text(
                          'Update your information',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personal Information card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: AppTextStyles.heading4,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            icon: Icons.person_outline,
                            label: 'Full Name',
                            controller: nameCtrl,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.phone_outlined,
                            label: 'Phone Number',
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            controller: locationCtrl,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.gavel_outlined,
                            label: 'Specialization',
                            controller: specializationCtrl,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.work_outline,
                            label: 'Experience (Years)',
                            controller: experienceCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Security card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Security', style: AppTextStyles.heading4),
                          const SizedBox(height: 14),
                          _buildField(
                            icon: Icons.lock_outline,
                            label: 'Current Password',
                            controller: currentPasswordCtrl,
                            obscureText: true,
                            isRequired: false,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            icon: Icons.lock_outline,
                            label: 'New Password (leave blank to keep current)',
                            controller: passwordCtrl,
                            obscureText: true,
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: AppButtonStyles.primary,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : Text('Save Changes', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Matches the Profile screen's row style — icon, label above, value below —
  // but with the value swapped for an editable TextFormField.
  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.beige.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.iconMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: AppTextStyles.heading4,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 2, bottom: 6),
                  ),
                  validator: (value) {
                    if (isRequired && (value == null || value.trim().isEmpty)) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}