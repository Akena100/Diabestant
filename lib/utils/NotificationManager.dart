import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  void initialize() {
    _requestPermission();
    _configureMessageHandlers();
    _setBackgroundMessageHandler();
    _getToken();
  }

  void _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _configureMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.messageId}');
      if (message.notification != null) {
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      }
      if (message.data.containsKey('data')) {
        streamCtlr.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtlr.sink.add(message.data['notification']);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.messageId}');
      if (message.notification != null) {
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      }
      if (message.data.containsKey('data')) {
        streamCtlr.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtlr.sink.add(message.data['notification']);
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('Initial message: ${message.messageId}');
        if (message.notification != null) {
          titleCtlr.sink.add(message.notification!.title!);
          bodyCtlr.sink.add(message.notification!.body!);
        }
        if (message.data.containsKey('data')) {
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          streamCtlr.sink.add(message.data['notification']);
        }
      }
    });
  }

  void _setBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  void _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  void dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}
