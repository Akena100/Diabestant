import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart'; // Ensure your BloodSugar model is implemented correctly
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatefulWidget {
  final String title;
  const LineChartWidget({super.key, required this.title});

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<BloodSugar> weeklyData = [];
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    fetchBloodSugarData();
  }

  // Function to fetch data from Firestore
  Future<void> fetchBloodSugarData() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Monday
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    // Fetch blood sugar data for the current week where type is equal to widget.title
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bloodSugarLogs')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: widget.title) // Filter by type
          .get();

      setState(() {
        weeklyData = snapshot.docs.map((doc) {
          return BloodSugar.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        print(
            "Fetched data for the current week: $weeklyData"); // Debug statement
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('$e'),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Use Expanded to allow the LineChart to take available height
        Expanded(
          child: weeklyData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LineChart(chartData),
        ),
      ],
    );
  }

  LineChartData get chartData => LineChartData(
        gridData: gridData,
        borderData: borderData,
        lineTouchData: lineTouchData,
        lineBarsData: lineBarsData,
        titlesData: titlesData,
        minY: 0,
        maxY: 20, // Extend Y-axis to 20
      );

  FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2, // Show even intervals
        checkToShowHorizontalLine: (double value) {
          return value % 2 == 0; // Show lines at even intervals
        },
      );

  FlBorderData get borderData => FlBorderData(show: false);

  LineTouchData get lineTouchData => const LineTouchData(
        enabled: false,
      );

  List<LineChartBarData> get lineBarsData => [
        firstLineBars,
        secondLineBars,
      ];

  LineChartBarData get firstLineBars => LineChartBarData(
        isCurved: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: const Color(0xFF5F6F52), // Color for Before Meal readings
        barWidth: 3,
        spots: getBeforeMealSpots(),
      );

  LineChartBarData get secondLineBars => LineChartBarData(
        isCurved: true,
        dotData: const FlDotData(show: false),
        color: const Color(0xFFCD5C08), // Color for After Meal readings
        barWidth: 3,
        spots: getAfterMealSpots(),
      );

  FlTitlesData get titlesData => FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitlesWidget,
            interval: 2, // Set interval to 2 for even numbers
            reservedSize: 30,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1, // Ensure every day is displayed
            getTitlesWidget: bottomTitlesWidget,
          ),
        ),
      );

  // Create spots for before meal readings
  List<FlSpot> getBeforeMealSpots() {
    final spots = weeklyData.asMap().entries.map((entry) {
      int index = entry.key;
      BloodSugar data = entry.value;
      return FlSpot(index.toDouble(), data.beforeBloodSugar);
    }).toList();

    print("Before Meal Spots: $spots"); // Debug statement
    return spots;
  }

  // Create spots for after meal readings
  List<FlSpot> getAfterMealSpots() {
    final spots = weeklyData.asMap().entries.map((entry) {
      int index = entry.key;
      BloodSugar data = entry.value;
      return FlSpot(index.toDouble(), data.afterBloodSugar);
    }).toList();

    print("After Meal Spots: $spots"); // Debug statement
    return spots;
  }

  Widget leftTitlesWidget(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(0), // Display integers for the Y-axis values
        style: style,
      ),
    );
  }

  // Update the bottomTitlesWidget function to ensure days are in order (Mon - Sun)
  Widget bottomTitlesWidget(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    String text;

    // Map the index to days of the week (0 = Monday, 6 = Sunday)
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 3,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
