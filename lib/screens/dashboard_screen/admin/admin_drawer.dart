import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Admin Panel'),
            ),

            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/admin-dashboard',
                );
              },
            ),

            ListTile(
              title: const Text('Manage Cases'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/manage-cases',
                );
              },
            ),

            ListTile(
              title: const Text('Manage Lawyers'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/manage-lawyers',
                );
              },
            ),
          ],
        ),
      ),

      body: child,
    );
  }
}