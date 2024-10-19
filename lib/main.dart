import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:diabestant/model/notifications_controller.dart';
import 'package:diabestant/presentation/appointment_details.dart';
import 'package:diabestant/presentation/screens/medication_details.dart';
import 'package:diabestant/presentation/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'presentation/screens/home_page.dart';
import 'presentation/screens/login.dart';
import 'presentation/screens/verify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD84NVbXkkzNrDpvXTuUxArBTcXrtpNBVE",
      authDomain: "diabestant.firebaseapp.com",
      projectId: "diabestant",
      storeBucket: "diabestant.appspot.com",
      messagingSenderId: "25128005252",
      appId: "1:25128005252:web:e71756c43f837d994e9cd1",
      measurementId: "G-54YDLPD8Q6",
    ),
  );

  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  runApp(const MyApp());
}

void initializeNotifications() {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {
      // Initialize the notification channels
      AwesomeNotifications().initialize(
        null, // Use null if you don’t want a default icon for notifications
        [
          NotificationChannel(
            channelGroupKey: 'reminders',
            channelKey: 'instant_notifications',
            channelName: 'Basic Instant Notification',
            channelDescription:
                'Notification channel for instant notifications.',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            soundSource: 'resource://raw/alarm', // Custom sound
            importance: NotificationImportance.High,
          ),
          NotificationChannel(
            channelKey: 'scheduled_channel',
            channelName: 'Scheduled Notifications',
            channelDescription:
                'Notification channel for scheduled notifications',
            defaultColor: Colors.teal,
            enableLights: true,
            enableVibration: true,
            playSound: true,
            importance: NotificationImportance.High,
          ),
          NotificationChannel(
            channelGroupKey: 'reminders',
            channelKey: 'scheduled_notifications',
            channelName: 'Scheduled Notification',
            channelDescription:
                'Notification channel for time-based notifications.',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            soundSource: 'resource://raw/alarm', // Custom sound
            importance: NotificationImportance.High,
          ),
        ],
      );
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String routeHome = '/',
      routeAppointmentDetails = '/appointment-details',
      routeMedicationDetails = '/medication-details';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabestant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: MyApp.navigatorKey,
      onGenerateRoute: (settings) {
        User user = FirebaseAuth.instance.currentUser!;
        switch (settings.name) {
          case routeHome:
            return MaterialPageRoute(
                builder: (_) => HomePage(
                      user: user,
                    ));
          case routeAppointmentDetails:
            final ReceivedAction receivedAction =
                settings.arguments as ReceivedAction;
            return MaterialPageRoute(
              builder: (_) => AppointmentDetailsPage(
                  appointmentId: receivedAction.payload!['appointmentId']!),
            );
          case routeMedicationDetails:
            final ReceivedAction receivedAction =
                settings.arguments as ReceivedAction;
            return MaterialPageRoute(
              builder: (_) => MedicationDetailsPage(
                  medicationId: receivedAction.payload!['medicationId']!),
            );
          default:
            return null;
        }
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          User? user = snapshot.data;
          if (snapshot.hasData) {
            return HomePage(user: user!);
          } else {
            return const Login();
          }
        },
      ),
      routes: {
        Register.id: (context) => const Register(),
        Login.id: (context) => const Login(),
        EmailVerificationInstructions.id: (context) =>
            const EmailVerificationInstructions(),
      },
    );
  }
}
