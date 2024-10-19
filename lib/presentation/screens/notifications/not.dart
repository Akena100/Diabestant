import 'package:flutter/material.dart';
import 'notify.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MyAppz extends StatefulWidget {
  const MyAppz({Key? key}) : super(key: key);

  @override
  _MyAppzState createState() => _MyAppzState();
}

class _MyAppzState extends State<MyAppz> {
  DateTime? _selectedDateTime;
  List<NotificationModel> _scheduledNotifications = [];

  // Function to pick date and time
  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Function to load scheduled notifications
  Future<void> _loadScheduledNotifications() async {
    List<NotificationModel> notifications =
        await Notify.retrieveScheduledNotifications();
    setState(() {
      _scheduledNotifications = notifications;
    });
  }

  // Function to cancel a notification
  Future<void> _cancelNotification(int id) async {
    await Notify.cancelNotification(id);
    _loadScheduledNotifications(); // Refresh the list after cancellation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                await Notify.instantNotify();
              },
              child: const Text("Instant Notification"),
            ),
            TextButton(
              onPressed: () async {
                await _pickDateTime(context); // Pick date and time
                if (_selectedDateTime != null) {
                  await Notify.scheduleNotification(
                      _selectedDateTime!); // Schedule notification
                }
              },
              child: const Text("Schedule Notification"),
            ),
            TextButton(
              onPressed: () async {
                await _loadScheduledNotifications(); // Retrieve scheduled notifications
              },
              child: const Text("Retrieve Scheduled Notifications"),
            ),
            Expanded(
              child: _scheduledNotifications.isNotEmpty
                  ? ListView.builder(
                      itemCount: _scheduledNotifications.length,
                      itemBuilder: (context, index) {
                        NotificationModel notification =
                            _scheduledNotifications[index];
                        return ListTile(
                          title:
                              Text(notification.content?.title ?? 'No title'),
                          subtitle:
                              Text(notification.content?.body ?? 'No body'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('ID: ${notification.content?.id}'),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () => _cancelNotification(
                                    notification.content!.id!),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : const Text("No scheduled notifications"),
            ),
          ],
        ),
      ),
    );
  }
}
