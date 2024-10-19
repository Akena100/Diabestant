import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:diabestant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class NotificationController {
  static ReceivedAction? initialAction;

  /// Initialize Notifications
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'reminders',
          channelKey: 'instant_notifications',
          channelName: 'Basic Instant Notification',
          channelDescription: 'Notification channel for instant notifications.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          playSound: true,
          soundSource: 'resource://raw/alarm', // Custom sound
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'mediation',
          channelName: 'Medications',
          channelDescription:
              'Notification channel for scheduled notifications',
          defaultColor: Colors.teal,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          soundSource: 'resource://raw/alarm', // Custom sound
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelGroupKey: 'reminders',
          channelKey: 'appointments',
          channelName: 'Appointments',
          channelDescription:
              'Notification channel for time-based notifications.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          playSound: true,
          soundSource: 'resource://raw/alarm', // Custom sound
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort()
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await executeLongTaskInBackground();
    } else {
      if (receivePort == null) {
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/appointment-details',
        (route) =>
            (route.settings.name != '/appointment-details') || route.isFirst,
        arguments: receivedAction);
  }

  static Future<void> createAppointmentNotification(
      String appointmentId) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'alerts',
        title: 'New Appointment!',
        body: 'You have an appointment scheduled.',
        payload: {
          'appointmentId': appointmentId
        }, // Pass appointment ID in the payload
      ),
    );
  }

  static Future<void> executeLongTaskInBackground() async {
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    await http.get(url);
  }
}
