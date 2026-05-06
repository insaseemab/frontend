// ============================================================
// admin_profile_page.dart
// Drop into your lib/ folder.
// In your bottom nav "Profile" tab, use: AdminProfilePage()
// ============================================================

import 'package:flutter/material.dart';

// ── Colors ────────────────────────────────────────────────────
class _C {
  static const brown   = Color(0xFF6B4226);
  static const brownMd = Color(0xFF8B5E3C);
  static const cream   = Color(0xFFF5EFE8);
  static const card    = Color(0xFFFFFFFF);
  static const txt1    = Color(0xFF2C1F14);
  static const txt2    = Color(0xFF8A7060);
  static const div     = Color(0xFFE8DDD4);
}

// ════════════════════════════════════════════════════════════════
// AdminProfilePage  ← plug into your bottom nav Profile tab
// ════════════════════════════════════════════════════════════════
class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.cream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Admin Profile',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _C.txt1,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          const Text('Manage your profile',
              style: TextStyle(fontSize: 13, color: _C.txt2)),
          const SizedBox(height: 24),
          _buildProfileCard(),
        ]),
      ),
    );
  }

  Widget _buildProfileCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: [
          const SizedBox(height: 6),
          CircleAvatar(
              radius: 38,
              backgroundColor: _C.brownMd,
              child: const Icon(Icons.person, size: 40, color: Colors.white)),
          const SizedBox(height: 14),
          const Text('Admin User',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.txt1)),
          const SizedBox(height: 4),
          const Text('System Administrator',
              style: TextStyle(fontSize: 12, color: _C.txt2)),
          const SizedBox(height: 20),
          const Divider(color: _C.div, height: 1),
          const SizedBox(height: 16),
          _row(Icons.email_outlined, 'admin@insaafconnect.com'),
          const SizedBox(height: 12),
          _row(Icons.phone_outlined, '+92 300 1234567'),
          const SizedBox(height: 12),
          _row(Icons.location_on_outlined, 'Islamabad, Pakistan'),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              child: const Text('Edit Profile',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );

  Widget _row(IconData ic, String t) => Row(children: [
        Icon(ic, size: 15, color: _C.brownMd),
        const SizedBox(width: 8),
        Expanded(
            child: Text(t,
                style: const TextStyle(fontSize: 12.5, color: _C.txt2),
                overflow: TextOverflow.ellipsis)),
      ]);
}