import 'package:get/get.dart';
import 'package:insaafconnect/routes/auth_middleware.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin_dashboard.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/screens/register_screen/register.dart';
import 'package:insaafconnect/screens/splash_screen/splash.dart';
import 'package:insaafconnect/screens/dashboard_screen/client_dashboard.dart';        // ← old admin screen
import 'package:insaafconnect/screens/dashboard_screen/admin_dashboard.dart'; // ← new client screen
import 'package:insaafconnect/screens/dashboard_screen/lawyer_dashboard.dart';        // ← lawyer screen

class AppRoutes {
  static const splash          = "/";
  static const login           = "/login";
  static const register        = "/register";
  static const clientDashboard = "/client-dashboard";  // ← new
  static const lawyerDashboard = "/lawyer-dashboard";  // ← new
  static const adminDashboard  = "/dashboard";   // ← new

  static List<GetPage> routes = [
    GetPage(name: splash,          page: () => SplashPage()),
    GetPage(name: login,           page: () => LoginScreen()),
    GetPage(name: register,        page: () => RegisterPage()),
    GetPage(name: clientDashboard, page: () => const ClientDashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: lawyerDashboard, page: () => LawyerDashboard(),             middlewares: [AuthMiddleware()]),
    GetPage(name: adminDashboard,  page: () => AdminProfileDashboard(),       middlewares: [AuthMiddleware()]),
  ];
}