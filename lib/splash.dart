import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Timer(const Duration(seconds: 3), () {
      Get.off(() => const LoginPage());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double opacity = (_controller.value + index * 0.3) % 1.0;
        return Opacity(opacity: opacity, child: child);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 5,
          backgroundColor: Color(0xFF6B4F3F),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE6DED3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Insaaf Connect",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342E),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Digital Platform for Lawyers and Clients",
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown,
              ),
            ),

            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
