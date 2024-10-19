import 'package:diabestant/notifications/notifications.dart';
import 'package:diabestant/presentation/login.dart';
import 'package:diabestant/presentation/screens/appointments.dart';
import 'package:diabestant/presentation/screens/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:diabestant/presentation/screens/home_page.dart';
import 'package:diabestant/presentation/screens/medication.dart';
import 'package:diabestant/presentation/widgets/line_chart.dart';
import 'package:diabestant/presentation/widgets/monthly_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RightSideCurveClipper(),
      child: Drawer(
        backgroundColor: Colors.white, // Whole background is white
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue, // Header background color
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/logo-db.png',
                    ),
                    radius: 40.0,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    user?.email ?? 'Not logged in',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.red), // Red icon
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(user: user!),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today,
                  color: Colors.green), // Green icon
              title: const Text(
                'Appointments',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.add, color: Colors.redAccent), // Purple icon
              title: const Text(
                'Blood Sugar',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BloodSugarLogsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood,
                  color: Colors.orange), // Orange icon
              title: const Text(
                'Meal Tracking',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealTrackerPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications,
                  color: Colors.purple), // Purple icon
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication_outlined,
                  color: Colors.blue), // Purple icon
              title: const Text(
                'Medication',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.logout, color: Colors.black), // Purple icon
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper class for adding a more pronounced curve to the right side of the drawer
class RightSideCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.75, 0); // Make curve start further left
    path.quadraticBezierTo(
      size.width,
      size.height * 0.5, // More pronounced curve
      size.width * 0.75,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // No need to reclip as it remains constant
  }
}
