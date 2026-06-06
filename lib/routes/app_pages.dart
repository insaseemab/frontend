import 'package:get/get.dart';

import 'app_routes.dart';
import 'auth_middleware.dart';

import '../screens/splash_screen/splash.dart';
import '../screens/login_screen/login.dart';
import '../screens/register_screen/register.dart';

import '../screens/dashboard_screen/admin/admin_dashboard.dart';
import '../screens/dashboard_screen/admin/appoint.dart';
import '../screens/dashboard_screen/admin/managelawyers.dart';
import '../screens/dashboard_screen/admin/manage_cases.dart';
import '../screens/dashboard_screen/admin/addlawyer.dart';
import '../screens/dashboard_screen/admin/createcase.dart';

import '../screens/dashboard_screen/client/client_dashboard.dart';
import '../screens/dashboard_screen/lawyer/lawyer_dashboard.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashPage(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
    ),

    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.manageLawyers,
      page: () => const Managelawyers(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.manageCases,
      page: () => const ManageCasesPage(),
      middlewares: [AuthMiddleware()],
    ),

    
    GetPage(
      name: AppRoutes.addLawyer,
      page: () => const AddLawyerPage(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.createCase,
      page: () => const CreateCasePage(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.clientDashboard,
      page: () => ClientDashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.lawyerDashboard,
      page: () => LawyerDashboard(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}