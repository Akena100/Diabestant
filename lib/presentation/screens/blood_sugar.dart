import 'dart:math';

import 'package:diabestant/presentation/screens/blood_sugar_details.dart';
import 'package:diabestant/presentation/screens/forms/blood_sugar.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/presentation/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class BloodSugarLogsPage extends StatefulWidget {
  const BloodSugarLogsPage({Key? key}) : super(key: key);

  @override
  BloodSugarLogsPageState createState() => BloodSugarLogsPageState();
}

class BloodSugarLogsPageState extends State<BloodSugarLogsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _bloodSugarLogsStream;
  int _selectedIndex = 0;
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _bloodSugarLogsStream = _firestore
        .collection('bloodSugarLogs')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Function to delete a blood sugar log
  Future<void> _deleteBloodSugarLog(String id) async {
    await _firestore.collection('bloodSugarLogs').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood Sugar Log deleted successfully')));
  }

  // Function to navigate to the blood sugar log form for editing
  void _editBloodSugarLog(String id, Map<String, dynamic> bloodSugarLogData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BloodSugarLogForm(
          logId: id,
          bloodSugarLogData: bloodSugarLogData,
        ),
      ),
    );
  }

  // Helper function to format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper function to convert dynamic to DateTime
  DateTime? _convertToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        // Try to parse the string as a DateTime
        return DateTime.parse(value);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }
    return null; // Return null if it's neither a Timestamp nor a String
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Blood Sugar Logs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bloodSugarLogsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'No Blood Sugar Logs Found!',
                    textStyle: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 1000),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var bloodSugarLogData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var logId = snapshot.data!.docs[index].id;

              // Convert the timestamps or strings to DateTime
              DateTime? beforeTime =
                  _convertToDateTime(bloodSugarLogData['beforeTime']);
              DateTime? afterTime =
                  _convertToDateTime(bloodSugarLogData['afterTime']);
              DateTime? date = _convertToDateTime(bloodSugarLogData['date']);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading:
                      const Icon(Icons.monitor, size: 40, color: Colors.blue),
                  title: Text(
                    'Before Level: ${bloodSugarLogData['beforeBloodSugar']} mg/dL\n'
                    'After Level: ${bloodSugarLogData['afterBloodSugar']} mg/dL\n'
                    '${bloodSugarLogData['type']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Before Time: ${beforeTime != null ? _formatDateTime(beforeTime) : 'N/A'}'),
                      Text(
                          'After Time: ${afterTime != null ? _formatDateTime(afterTime) : 'N/A'}'),
                      Text(
                          'Date: ${date != null ? _formatDateTime(date) : 'N/A'}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editBloodSugarLog(logId, bloodSugarLogData);
                      } else if (value == 'delete') {
                        _deleteBloodSugarLog(logId);
                      } else if (value == 'view') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BloodSugarDetailsPage(
                                    bloodSugarId: logId)));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BloodSugarLogForm()),
          ).then((result) {
            if (result == 'added') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Blood Sugar Log added successfully!')));
            }
          });
        },
        child: const Icon(Icons.add),
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
