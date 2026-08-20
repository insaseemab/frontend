import 'package:get/get.dart';
import 'auth_middleware.dart';

import 'package:insaafconnect/screens/chat/message.dart';
import 'package:insaafconnect/screens/chat/conversation.dart';
import '../screens/splash_screen/splash.dart';
import '../screens/login_screen/login.dart';
import '../screens/register_screen/register.dart';
import '../screens/login_screen/forgot_password.dart';
import '../screens/login_screen/reset_password.dart';
import '../screens/dashboard_screen/admin/admin_dashboard.dart';
import '../screens/dashboard_screen/admin/managelawyers.dart';
import '../screens/dashboard_screen/admin/manage_cases.dart';
import '../screens/dashboard_screen/admin/addlawyer.dart';
import '../screens/dashboard_screen/admin/createcase.dart';
import '../screens/dashboard_screen/client/client_dashboard.dart';
import '../screens/dashboard_screen/client/lawyer_find.dart';
import '../screens/dashboard_screen/client/calendar.dart';
import '../screens/dashboard_screen/lawyer/lawyer_dashboard.dart';
import '../screens/appointments/appointments_page.dart';
import '../screens/notifications.dart';
import '../screens/dashboard_screen/profile.dart';
import '../screens/dashboard_screen/admin/settings_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  static const resetPassword = "/reset-password";

  static const adminDashboard = "/admin-dashboard";
  static const manageLawyers = "/manage-lawyers";
  static const manageCases = "/manage-cases";
  static const adminProfile = "/admin-profile";
  static const addLawyer = "/add-lawyer";
  static const createCase = "/create-case";

  static const clientDashboard = "/client-dashboard";
  static const lawyerFind = '/lawyer-find';
  static const lawyerProfile = '/lawyer-profile';
  static const bookAppointment = '/book-appointment';
  static const myAppointments = '/my-appointments';
  static const calendar = '/calendar';

  static const messages = '/messages';
  static const message = '/message';

  static const lawyerDashboard = "/lawyer-dashboard";

  static const appointments = '/appointments';
   static const notifications = '/notifications';
  static const profile = '/profile';
  static const adminSettings = '/admin-settings';
}


// PAGES
class AppPages {
  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => SplashPage()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => RegisterPage()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),

    
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.manageLawyers,
      page: () => const Managelawyers(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.manageCases,
      page: () {
        final args = Get.arguments;
        final userRole =
            (args is Map && args['userRole'] != null)
                ? args['userRole'] as String
                : 'admin';
        return ManageCasesPage(userRole: userRole);
      },
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin', 'lawyer', 'client']),
      ],
    ),
    GetPage(
      name: AppRoutes.addLawyer,
      page: () => const AddLawyerPage(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.createCase,
      page: () => const CreateCasePage(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin', 'lawyer']),
      ],
    ),

    
    GetPage(
      name: AppRoutes.clientDashboard,
      page: () => ClientDashboardScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['client']),
      ],
    ),
    GetPage(
      name: AppRoutes.lawyerFind,
      page: () => const LawyerFindScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['client']),
      ],
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarScreen(),
      middlewares: [
        RoleMiddleware(allowedRoles: ['client', 'lawyer', 'admin']),
      ],
    ),

    
    GetPage(
      name: AppRoutes.messages,
      page: () => const ConversationsScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['client', 'lawyer']),
      ],
    ),
    GetPage(
      name: AppRoutes.message,
      page: () => const MessageScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['client', 'lawyer']),
      ],
    ),


    GetPage(
      name: AppRoutes.lawyerDashboard,
      page: () => LawyerDashboard(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['lawyer']),
      ],
    ),


    GetPage(
      name: AppRoutes.appointments,
      page: () {
        final args = Get.arguments;
        final roleStr =
            (args is Map && args['role'] != null) ? args['role'] as String : 'client';
        final role = _appointmentRoleFromString(roleStr);
        return AppointmentsPage(role: role);
      },
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin', 'lawyer', 'client']),
      ],
    ),
  
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const SettingsScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['admin']),
      ],
    ),
  ];

  static AppointmentRole _appointmentRoleFromString(String role) {
    switch (role) {
      case 'lawyer':
        return AppointmentRole.lawyer;
      case 'admin':
        return AppointmentRole.admin;
      case 'client':
      default:
        return AppointmentRole.client;
    }
  }
}