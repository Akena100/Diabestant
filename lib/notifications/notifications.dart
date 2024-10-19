import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  // Function to load all scheduled notifications
  Future<void> _loadScheduledNotifications() async {
    List<NotificationModel> notifications =
        await AwesomeNotifications().listScheduledNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  // Function to cancel a specific notification
  Future<void> _cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Notification $id canceled')));
    _loadScheduledNotifications();
  }

  // Function to cancel all notifications
  Future<void> _cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications canceled')));
    _loadScheduledNotifications();
  }

  // Function to refresh the list of notifications
  Future<void> _refreshNotifications() async {
    await _loadScheduledNotifications();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('List refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Button to cancel all notifications
            ElevatedButton(
              onPressed: _cancelAllNotifications,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: Text('Cancel All Notifications'),
            ),
            const SizedBox(height: 20),

            // Display a list of scheduled notifications
            Expanded(
              child: _notifications.isEmpty
                  ? Center(child: Text('No scheduled notifications'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        NotificationModel notification = _notifications[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                'Notification ID: ${notification.content!.id}'),
                            subtitle: Text(
                                'Title: ${notification.content!.title ?? "No Title"}\n'
                                'Body: ${notification.content!.body ?? "No Body"}\n'
                                'Scheduled for: ${notification.schedule?.toString() ?? "No Schedule"}'),
                            trailing: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () => _cancelNotification(
                                  notification.content!.id!),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
