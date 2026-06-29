import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();

    if (box.read('token') == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  final String role;

  RoleMiddleware({required this.role});

  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();

    // Read the user's role from GetStorage
    final userRole = box.read('role');

    if (userRole == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (userRole != role) {
      // Redirect if the role doesn't match
      return const RouteSettings(name: AppRoutes.login);
      // Or use an Access Denied page if you have one.
    }

    return null;
  }
}