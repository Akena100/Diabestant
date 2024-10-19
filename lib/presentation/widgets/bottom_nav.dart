import 'package:diabestant/notifications/notifications.dart';
import 'package:diabestant/presentation/screens/appointments.dart';
import 'package:diabestant/presentation/screens/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:diabestant/presentation/screens/forms/appointments.dart';
import 'package:diabestant/presentation/screens/forms/medication.dart';
import 'package:diabestant/presentation/screens/home_page.dart';
import 'package:diabestant/presentation/screens/medication.dart';
import 'package:diabestant/presentation/screens/pills.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  final int selectedIndex;
  final void Function(int) onItemTapped;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Food'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.article), label: 'Appointment'),
        BottomNavigationBarItem(
            icon: Icon(Icons.medication), label: 'Medication'),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        onItemTapped(index);

        switch (index) {
          case 0:
            print('Home tapped');
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePage(user: user)));
            break;
          case 1:
            print('Food tapped');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MealTrackerPage()),
            );
            break;
          case 2:
            print('Add tapped');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BloodSugarLogsPage()),
            );
            break;
          case 3:
            print('Record tapped');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppointmentsPage()),
            );

            break;
          case 4:
            print('Profile tapped');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicationsPage()),
            );

            break;
        }
      },
    );
  }
}
