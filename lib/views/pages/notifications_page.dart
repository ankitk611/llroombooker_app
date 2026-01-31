import 'dart:convert';
import 'package:roombooker/core/methods/token_methods.dart';
import 'package:roombooker/core/constants/url.dart';
//import 'package:roombooker/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:roombooker/core/models/notification_model.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // fetchNotifications() → already discussed earlier


Future<void> fetchNotifications() async {
  try {
    final token = await TokenUtils().getBearerToken();

    final response = await http.get(
      Uri.parse('${Url.baseUrl}/users/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      final List unreadList = data['unread'] ?? [];
      final List readList = data['read'] ?? [];

      final unreadNotifications = unreadList
          .map((e) => AppNotification.fromJson(e, isRead: false))
          .toList();
      final readNotifications = readList
          .map((e) => AppNotification.fromJson(e, isRead: true))
          .toList();

      

      /// ✅ ORDER: READ FIRST, THEN UNREAD
      setState(() {
        notifications = [
          ...unreadNotifications,
          ...readNotifications,
          
        ];
      });
    }
  } catch (e) {
    debugPrint('Notification error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];

                    /// 👇 YOUR ListTile GOES HERE
                    return ListTile(
                      leading: Icon(
                        n.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: n.isRead ? Colors.grey : Colors.red,
                      ),
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight:
                              n.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(n.message),
                      trailing: Text(
                        '${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        // optional: mark as read / open details
                      },
                    );
                  },
                ),
    );
  }
}



