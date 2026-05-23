import 'package:get/get.dart';
import 'package:insaafconnect/routes/auth_middleware.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin/admin_dashboard.dart';
import 'package:insaafconnect/screens/login_screen/login.dart';
import 'package:insaafconnect/screens/register_screen/register.dart';
import 'package:insaafconnect/screens/splash_screen/splash.dart';
import 'package:insaafconnect/screens/dashboard_screen/client/client_dashboard.dart';      
import 'package:insaafconnect/screens/dashboard_screen/lawyer/lawyer_dashboard.dart';       

class AppRoutes {
  static const splash          = "/";
  static const login           = "/login";
  static const register        = "/register";
  static const clientDashboard = "/client_dashboard";  
  static const lawyerDashboard = "/lawyer_dashboard";  
  static const adminDashboard  = "/dashboard";  

  static List<GetPage> routes = [
    GetPage(name: splash,          page: () => SplashPage()),
    GetPage(name: login,           page: () => LoginScreen()),
    GetPage(name: register,        page: () => RegisterPage()),
    GetPage(name: clientDashboard, page: () => ClientDashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: lawyerDashboard, page: () => LawyerDashboard(),             middlewares: [AuthMiddleware()]),
    GetPage(name: adminDashboard,  page: () => AdminDashboardScreen(),       middlewares: [AuthMiddleware()]),
  ];
}