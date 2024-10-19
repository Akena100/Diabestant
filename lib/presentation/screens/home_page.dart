import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/notifications/notifications.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:diabestant/presentation/screens/forms/basic_details.dart';
import 'package:diabestant/presentation/screens/notifications/not.dart';
import 'package:diabestant/presentation/screens/pills.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/presentation/widgets/chart_label.dart';
import 'package:diabestant/presentation/widgets/circular_chart.dart';
import 'package:diabestant/presentation/widgets/drawer.dart';
import 'package:diabestant/presentation/widgets/info_card.dart';
import 'package:diabestant/presentation/widgets/line_chart.dart';
import 'package:diabestant/presentation/widgets/map.dart';
import 'package:diabestant/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diabestant/ai.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final User? user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userId = ""; // To hold the user's ID
  String age = ""; // To hold user's age
  String name = "";
  String gender = "";
  String weight = "";
  String diabetesType = ""; // To hold user's diabetes type

  @override
  void initState() {
    super.initState();

    fetchUserData();
  }

  void fetchUserData() async {
    // Get current user ID
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      userId = currentUser.uid; // Get the current user's ID

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Assuming the user document has 'age' and 'diabetesType' fields
        setState(() {
          age = userDoc['age'] ?? ""; // Fetch age from Firestore
          diabetesType = userDoc['diabetesType'] ??
              ""; // Fetch diabetes type from Firestore
          name = userDoc['name'] ?? "";
          weight = userDoc['weight'] ?? "";
          gender = userDoc['gender'] ?? "";
          // Call to generate text after fetching user data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MapPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 24),
                children: [
                  const TextSpan(text: 'Hello ,\n'),
                  TextSpan(
                    text: '$name 👋',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Circular Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularChart(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChartLabel('Blood Sugar', Colors.green),
                      const SizedBox(height: 8),
                      ChartLabel('Glycemic load', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoCard(
                    icon: Icons.local_dining,
                    title: 'Carbs',
                    value: '522 calories',
                    color: Colors.blue),
                InfoCard(
                    icon: Icons.medication,
                    title: 'Pills',
                    value: '00 taken',
                    color: Colors.purple),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoCard(
                    icon: Icons.bloodtype,
                    title: 'Glucose',
                    value: '116 mg/dl',
                    color: Colors.red),
                InfoCard(
                    icon: Icons.medication,
                    title: 'Pills',
                    value: '00 taken',
                    color: Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            // Glucose Line Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Week: BreakFast',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text('Glucose'),
                  buildLegend(),
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: 150, // Set a specific height
                    child: LineChartWidget(title: "Breakfast"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Glucose Line Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Week: Lunch',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text('Glucose'),
                  buildLegend(),
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: 150, // Set a specific height
                    child: LineChartWidget(title: 'Lunch'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Glucose Line Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Week: Dinner',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text('Glucose'),
                  buildLegend(),
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: 150, // Set a specific height
                    child: LineChartWidget(title: 'Dinner'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Function to build the legend
Widget buildLegend() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      LegendItem(color: Color(0xFF5F6F52), text: 'Before Meal'),
      SizedBox(width: 20),
      LegendItem(color: Color(0xFFCD5C08), text: 'After Meal'),
    ],
  );
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
