import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/core/services/api_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = GetStorage();
  late Map<String, dynamic> user;
  late String role;

  final Color darkBrown = AppColors.darkBrown;
  final Color mediumBrown = AppColors.mediumBrown;
  final Color muted = AppColors.labelSecondary;
  final Color bg = AppColors.beige;
  final Color cardBorder = AppColors.divider;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final rawUser = box.read('user');
    if (rawUser is Map) {
      user = Map<String, dynamic>.from(rawUser);
    } else {
      user = {};
    }
    if (user['name'] == null && box.read('userName') != null) {
      user['name'] = box.read('userName');
    }
    if (user['id'] == null && box.read('userId') != null) {
      user['id'] = box.read('userId');
    }
    role = (box.read('role') ?? user['role'] ?? '').toString();
  }

  int get _userId {
    final dynamic rawId = user['id'] ?? box.read('userId');
    if (rawId == null) return 0;
    return int.tryParse(rawId.toString()) ?? 0;
  }

  Future<void> _openEditSheet() async {
    final nameCtrl = TextEditingController(
      text: (user['name'] ?? box.read('userName') ?? '').toString(),
    );
    final emailCtrl = TextEditingController(
      text: (user['email'] ?? '').toString(),
    );
    final phoneCtrl = TextEditingController(
      text: (user['phone'] ?? '').toString(),
    );
    final locationCtrl = TextEditingController(
      text: (user['location'] ?? '').toString(),
    );

    // Lawyer-only fields
    final specCtrl = TextEditingController(
      text: (user['specialization'] ?? '').toString(),
    );
    final expCtrl = TextEditingController(
      text: (user['experience'] ?? '').toString(),
    );

    final isLawyer = role.toLowerCase() == 'lawyer';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBrown)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                if (isLawyer) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: specCtrl,
                    decoration: const InputDecoration(labelText: 'Specialization'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: expCtrl,
                    decoration: const InputDecoration(labelText: 'Experience'),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mediumBrown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final updatedData = {
                        'name': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'location': locationCtrl.text.trim(),
                        if (isLawyer) 'specialization': specCtrl.text.trim(),
                        if (isLawyer) 'experience': expCtrl.text.trim(),
                      };
                      await _saveProfile(updatedData);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Save Changes',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openChangePasswordSheet() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBrown)),
                const SizedBox(height: 16),
                TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mediumBrown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (newCtrl.text.trim() != confirmCtrl.text.trim()) {
                        Get.snackbar('Error', 'New passwords do not match');
                        return;
                      }
                      if (newCtrl.text.trim().isEmpty ||
                          currentCtrl.text.trim().isEmpty) {
                        Get.snackbar('Error', 'Please fill in all fields');
                        return;
                      }
                      await _changePassword(
                        currentCtrl.text.trim(),
                        newCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Update Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final userId = _userId;
      if (userId == 0) {
        Get.snackbar('Error', 'User ID not found. Please log in again.');
        return;
      }
      await ApiService.changePassword(
        id: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      Get.snackbar('Success', 'Password updated successfully');
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> updatedData) async {
    try {
      final userId = _userId;
      if (userId == 0) {
        Get.snackbar('Error', 'User ID not found. Please log in again.');
        return;
      }
      final response = await ApiService.updateProfile(
        id: userId,
        data: updatedData,
      );

      final newUser = {...user, ...response};
      await box.write('user', newUser);
      if (newUser['name'] != null) {
        await box.write('userName', newUser['name'].toString());
      }
      setState(() {
        user = newUser;
      });
      Get.snackbar('Success', 'Profile updated successfully');
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = (user['name'] ?? 'Unknown').toString();
    final String email = (user['email'] ?? 'Not provided').toString();
    final String phone = (user['phone'] ?? 'Not provided').toString();
    final String location = (user['location'] ?? 'Not provided').toString();
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            Text(
              'Manage your account',
              style: TextStyle(
                fontSize: 12,
                color: muted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: mediumBrown,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role.isNotEmpty
                              ? role[0].toUpperCase() + role.substring(1)
                              : '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openEditSheet,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: mediumBrown,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Personal Information ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: darkBrown,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoField(Icons.person_outline, 'Full Name', name),
                  const SizedBox(height: 12),
                  _infoField(Icons.email_outlined, 'Email Address', email),
                  const SizedBox(height: 12),
                  _infoField(Icons.phone_outlined, 'Phone Number', phone),
                  const SizedBox(height: 12),
                  _infoField(Icons.location_on_outlined, 'Location', location),

                  // ── Lawyer-only fields ──
                  if (role.toLowerCase() == 'lawyer') ...[
                    const SizedBox(height: 12),
                    _infoField(
                      Icons.gavel,
                      'Specialization',
                      (user['specialization'] ?? 'Not provided').toString(),
                    ),
                    const SizedBox(height: 12),
                    _infoField(
                      Icons.work_outline,
                      'Experience',
                      (user['experience'] ?? 'Not provided').toString(),
                    ),
                    const SizedBox(height: 12),
                    _infoField(
                      Icons.folder_outlined,
                      'Cases Handled',
                      (user['cases'] ?? 'Not provided').toString(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Change Password ──
            InkWell(
              onTap: _openChangePasswordSheet,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: mediumBrown),
                      SizedBox(width: 8),
                      Text(
                        'Change Password',
                        style: TextStyle(
                          color: mediumBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Logout ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  box.erase();
                  Get.offAll(() => LoginScreen());
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Field rendered as its own light card, like the mockup
  Widget _infoField(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}