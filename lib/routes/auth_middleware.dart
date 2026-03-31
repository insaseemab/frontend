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