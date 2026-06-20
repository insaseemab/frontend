class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const register = "/register";

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

  // Conversation list (role-aware: client sees lawyers, lawyer sees clients)
  static const messages = '/messages';
  // Single chat thread — always navigated to WITH arguments
  // (conversation_id, receiver_id, other_name) from ConversationsScreen.
  static const message = '/message';

  static const lawyerDashboard = "/lawyer-dashboard";
  // NOTE: removed lawyerMessages ('/lawyer-messages') — dead route.
  // ConversationsScreen now serves both lawyer and client via the
  // single `messages` route above; backend's /conversations/mine
  // branches by role server-side.
}