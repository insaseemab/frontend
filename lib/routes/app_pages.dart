import 'package:get/get.dart';

import 'app_routes.dart';
import 'auth_middleware.dart';

import '../screens/splash_screen/splash.dart';
import '../screens/login_screen/login.dart';
import '../screens/register_screen/register.dart';

import '../screens/dashboard_screen/admin/admin_dashboard.dart';
import '../screens/dashboard_screen/admin/managelawyers.dart';
import '../screens/dashboard_screen/admin/manage_cases.dart';

import '../screens/dashboard_screen/client/client_dashboard.dart';
import '../screens/dashboard_screen/client/lawyer_find.dart';
import '../screens/dashboard_screen/client/calendar.dart';

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

    // ── Admin ──
GetPage(
  name: AppRoutes.adminDashboard,
  page: () => const AdminDashboardScreen(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'admin'),
  ],
),

GetPage(
  name: AppRoutes.manageLawyers,
  page: () => const Managelawyers(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'admin'),
  ],
),

GetPage(
  name: AppRoutes.manageCases,
  page: () => const ManageCasesPage(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'admin'),
  ],
),

// ── Client ──
GetPage(
  name: AppRoutes.clientDashboard,
  page: () => ClientDashboardScreen(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'client'),
  ],
),

GetPage(
  name: AppRoutes.lawyerFind,
  page: () => const LawyerFindScreen(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'client'),
  ],
),

GetPage(
  name: AppRoutes.calendar,
  page: () => const CalendarScreen(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'client'),
  ],
),

// ── Lawyer ──
GetPage(
  name: AppRoutes.lawyerDashboard,
  page: () => LawyerDashboard(),
  middlewares: [
    AuthMiddleware(),
    RoleMiddleware(role: 'lawyer'),
  ],
),
  ];
}