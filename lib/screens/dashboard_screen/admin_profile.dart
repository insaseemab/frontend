import 'package:flutter/material.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin_dashboard.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      // ───────── APP BAR ─────────
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,

        // BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          },
        ),

        title: const Text(
          "Admin Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ───────── BODY ─────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUBTITLE
            const Text(
              "Manage your profile",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),

            const SizedBox(height: 20),

            // ───────── PROFILE CARD ─────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // PROFILE IMAGE
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.brown,

                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // NAME
                  const Text(
                    "Admin User",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ROLE
                  const Text(
                    "System Administrator",
                    style: TextStyle(fontSize: 14, color: Colors.brown),
                  ),

                  const SizedBox(height: 20),

                  // DIVIDER
                  const Divider(color: Colors.brown, thickness: 1),

                  const SizedBox(height: 20),

                  // EMAIL
                  _buildInfoRow(
                    Icons.email_outlined,
                    "admin@insaafconnect.com",
                  ),

                  const SizedBox(height: 15),

                  // PHONE
                  _buildInfoRow(Icons.phone_outlined, "+92 300 1234567"),

                  const SizedBox(height: 15),

                  // LOCATION
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "Islamabad, Pakistan",
                  ),

                  const SizedBox(height: 25),

                  // EDIT BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        // ADD EDIT FUNCTION HERE
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        elevation: 0,
                      ),

                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── INFO ROW WIDGET ─────────
  static Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown, size: 20),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
