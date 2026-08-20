// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:insaafconnect/core/services/notifications_services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/routes/app_routes.dart'; 
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<dynamic> _notifications = [];
  int _unread = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getNotifications();
      setState(() {
        _notifications = data['notifications'];
        _unread = data['unread'] is String
            ? int.parse(data['unread'])
            : data['unread'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(int id, int index) async {
    try {
      await _service.markAsRead(id);
      setState(() {
        _notifications[index]['is_read'] = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllRead();
      setState(() {
        _notifications = _notifications
            .map((n) => {...n, 'is_read': 1})
            .toList();
        _unread = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF1ECE5),  
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFFF1ECE5),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text("Mark all read",
              style: TextStyle(
              color: Color(0xFF3E2C23))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(child: Text("No notifications yet")),
                ],
              )
            : ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    itemCount: _notifications.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final n = _notifications[index];
      final isRead = n['is_read'] == 1 || n['is_read'] == true;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () async {
  await _markRead(n['id'], index);

  final role = GetStorage().read('role'); // 'admin' | 'lawyer' | 'client'

  if (n['type'] == 'appointment') {
    Get.toNamed(AppRoutes.appointments, arguments: {'role': role ?? 'client'});
  } else if (n['type'] == 'case') {
    Get.toNamed(AppRoutes.manageCases, arguments: {'userRole': role ?? 'client'});
  }
},
                    tileColor: isRead
                        ? Colors.transparent
                        : Colors.white,
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? Colors.white
                          : Colors.brown,
                      child: Icon(
                        Icons.notifications,
                        color: isRead ? const Color(0xFFF1ECE5) : Colors.white,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      n['title'] ?? '',
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(n['body'] ?? ''),
                    trailing: !isRead
                        ? Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
      );
      
                },
              ),
      ),
    );
  }
}
