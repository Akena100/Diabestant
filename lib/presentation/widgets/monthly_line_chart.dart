import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart'; // Ensure your BloodSugar model is implemented correctly
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget1 extends StatefulWidget {
  const LineChartWidget1({Key? key}) : super(key: key);

  @override
  _LineChartWidget1State createState() => _LineChartWidget1State();
}

class _LineChartWidget1State extends State<LineChartWidget1> {
  List<BloodSugar> monthlyData = [];

  @override
  void initState() {
    super.initState();
    fetchBloodSugarData();
  }

  // Function to fetch data from Firestore for the current month
  Future<void> fetchBloodSugarData() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth =
        DateTime(now.year, now.month + 1, 0); // Last day of the month

    // Fetch blood sugar data for the current month
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('bloodSugarLogs')
        .orderBy('date')
        .get();

    setState(() {
      monthlyData = snapshot.docs.map((doc) {
        return BloodSugar.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      print("Fetched data: $monthlyData"); // Debug statement
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: monthlyData.isEmpty
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
        maxY: 10, // Adjust this based on expected blood sugar levels
      );

  FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        checkToShowHorizontalLine: (double value) {
          return value == 1 || value == 3 || value == 5 || value == 7;
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
            interval: 1,
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
            interval: 1,
            getTitlesWidget: bottomTitlesWidget,
          ),
        ),
      );

  // Create spots for before meal readings
  List<FlSpot> getBeforeMealSpots() {
    final spots = monthlyData.asMap().entries.map((entry) {
      int index = entry.key;
      BloodSugar data = entry.value;
      return FlSpot(index.toDouble(), data.beforeBloodSugar);
    }).toList();

    print("Before Meal Spots: $spots"); // Debug statement
    return spots;
  }

  // Create spots for after meal readings
  List<FlSpot> getAfterMealSpots() {
    final spots = monthlyData.asMap().entries.map((entry) {
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
        value.toStringAsFixed(0),
        style: style,
      ),
    );
  }

  Widget bottomTitlesWidget(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    String text;
    if (value.toInt() < monthlyData.length) {
      text = DateFormat('dd').format(monthlyData[value.toInt()].date);
    } else {
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
