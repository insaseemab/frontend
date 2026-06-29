import 'package:get/get.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';
import 'package:insaafconnect/screens/chat/message.dart';
import 'package:insaafconnect/screens/chat/conversation.dart';
import '../screens/splash_screen/splash.dart';
import '../screens/login_screen/login.dart';
import '../screens/register_screen/register.dart';
import '../screens/dashboard_screen/admin/admin_dashboard.dart';
import '../screens/dashboard_screen/admin/managelawyers.dart';
import '../screens/dashboard_screen/admin/manage_cases.dart';
import '../screens/dashboard_screen/admin/addlawyer.dart';
import '../screens/dashboard_screen/admin/createcase.dart';
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
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['admin'])],
    ),
    GetPage(
      name: AppRoutes.manageLawyers,
      page: () => const Managelawyers(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['admin'])],
    ),
    GetPage(
      name: AppRoutes.manageCases,
      page: () => const ManageCasesPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['admin'])],
    ),
    GetPage(
      name: AppRoutes.addLawyer,
      page: () => const AddLawyerPage(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['admin'])],
    ),
    GetPage(
      name: AppRoutes.createCase,
      page: () => const CreateCasePage(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['admin'])],
    ),

    // ── Client ──
    GetPage(
      name: AppRoutes.clientDashboard,
      page: () => ClientDashboardScreen(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['client'])],
    ),
    GetPage(
      name: AppRoutes.lawyerFind,
      page: () => const LawyerFindScreen(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['client'])],
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarScreen(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['client'])],
    ),

    // ── Chat (shared by client + lawyer) ──
    GetPage(
      name: AppRoutes.messages,
      page: () => const ConversationsScreen(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['client', 'lawyer'])],
    ),
    GetPage(
      name: AppRoutes.message,
      page: () => const MessageScreen(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['client', 'lawyer'])],
    ),

    // ── Lawyer ──
    GetPage(
      name: AppRoutes.lawyerDashboard,
      page: () => LawyerDashboard(),
      middlewares: [AuthMiddleware(), RoleMiddleware(allowedRoles: ['lawyer'])],
    ),
  ];
}