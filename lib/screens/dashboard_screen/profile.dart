import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final Map<String, dynamic> user =
        Map<String, dynamic>.from(box.read('user') ?? {});
    final String role = (box.read('role') ?? user['role'] ?? '').toString();

    final String name = (user['name'] ?? 'Unknown').toString();
    final String email = (user['email'] ?? 'Not provided').toString();
    final String location = (user['location'] ?? 'Not provided').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2C23)),
            ),
            Text(
              'Manage your account',
              style: TextStyle(fontSize: 12, color: Color(0xFF8C7B6B), fontWeight: FontWeight.normal),
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
                border: Border.all(color: const Color(0xFFEADDD0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF6B4F3F),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : '',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
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
                border: Border.all(color: const Color(0xFFEADDD0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  _infoRow(Icons.person_outline, 'Full Name', name),
                  const SizedBox(height: 12),
                  _infoRow(Icons.email_outlined, 'Email Address', email),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined, 'Location', location),

                  // ── Lawyer-only fields (these columns only exist for role = lawyer) ──
                  if (role.toLowerCase() == 'lawyer') ...[
                    const SizedBox(height: 12),
                    _infoRow(Icons.gavel, 'Specialization',
                        (user['specialization'] ?? 'Not provided').toString()),
                    const SizedBox(height: 12),
                    _infoRow(Icons.work_outline, 'Experience',
                        (user['experience'] ?? 'Not provided').toString()),
                    const SizedBox(height: 12),
                    _infoRow(Icons.folder_outlined, 'Cases Handled',
                        (user['cases'] ?? 'Not provided').toString()),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  box.erase();
                  Get.offAll(() => LoginScreen());
                },
                icon: const Icon(Icons.logout, color: Color(0xFF6B4F3F)),
                label: const Text('Logout', style: TextStyle(color: Color(0xFF6B4F3F))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF6B4F3F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8C7B6B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8C7B6B))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}