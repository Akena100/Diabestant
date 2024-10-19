import 'package:diabestant/notifications/notifications.dart';
import 'package:diabestant/presentation/screens/appointments.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:diabestant/presentation/screens/forms/appointments.dart';
import 'package:diabestant/presentation/screens/home_page.dart';
import 'package:diabestant/presentation/screens/pills.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final User user;

  const MainPage({super.key, required this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Declare the screens list
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize the screens list using the user from the widget
    _screens = [
      HomePage(user: widget.user),
      MealTrackerPage(),
      Container(), // Placeholder for the 'Add' screen (optional)
      AppointmentsPage(),
      PillsPage(
        x: '',
      ), // Replace with your actual Profile screen
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
