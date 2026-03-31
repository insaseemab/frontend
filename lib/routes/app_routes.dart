import 'package:get/get.dart';
import 'package:insaafconnect/routes/auth_middleware.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/screens/register_screen/register.dart';
import 'package:insaafconnect/screens/splash_screen/splash.dart';
import 'package:insaafconnect/screens/dashboard_screen/client_dashboard.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const register = "/register";
  static const dashboard = "/dashboard";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => SplashPage()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterPage()),
    GetPage(name: dashboard, page: () => DashboardScreen() , middlewares: [AuthMiddleware()]),
  ];
}