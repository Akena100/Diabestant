import 'package:awesome_notifications/awesome_notifications.dart';

class Notify {
  // Function for instant notification
  static Future<void> instantNotify() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'instant_notifications',
        title: 'Instant Notification',
        body: 'This is an instant notification!',
      ),
    );
  }

  // Function to schedule notification at specific time
  static Future<void> scheduleNotification(DateTime scheduledTime) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'scheduled_channel',
        title: 'Scheduled Notification',
        body: 'This notification was scheduled!',
      ),
      schedule: NotificationCalendar(
        year: scheduledTime.year,
        month: scheduledTime.month,
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
    );
  }

  // Function to schedule a recurring notification (every X seconds)
  static Future<void> scheduleRecurringNotification() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'scheduled_channel',
        title: 'Recurring Notification',
        body: 'This notification repeats every few hours.',
      ),
      schedule: NotificationInterval(
        interval: 60, // e.g., 2 hours (7200 seconds)
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true, // Important for repeating notifications
      ),
    );
  }

  // Function to retrieve scheduled notifications
  static Future<List<NotificationModel>>
      retrieveScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  // Function to cancel a specific notification by its ID
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Function to cancel all repeating or scheduled notifications
  static Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
