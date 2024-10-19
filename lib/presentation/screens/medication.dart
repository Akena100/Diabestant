import 'package:diabestant/presentation/screens/medication_details.dart';
import 'package:diabestant/presentation/screens/meds.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/presentation/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import 'package:diabestant/presentation/screens/forms/medication.dart'; // Import your MedicationForm

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({Key? key}) : super(key: key);

  @override
  MedicationsPageState createState() => MedicationsPageState();
}

class MedicationsPageState extends State<MedicationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _medicationsStream;
  int _selectedIndex = 0;
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    // Fetch medications where 'userId' matches the current Firebase user's ID
    _medicationsStream = _firestore
        .collection('medications')
        .where('userId', isEqualTo: user.uid) // Changed to 'userId'
        .snapshots();
  }

  // Function to delete a medication
  Future<void> _deleteMedication(String id) async {
    await _firestore.collection('medications').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication deleted successfully')));
  }

  // Function to navigate to the medication form for editing
  void _editMedication(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationForm(
          medicationId: id,
          // You can pass the medicationId and medicationData here if needed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _medicationsStream,
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
                    'No Medications Found!',
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
              var medicationData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var medicationId = snapshot.data!.docs[index].id;

              // Parse the dates
              DateTime startDate = DateTime.parse(medicationData['startDate']);
              String formattedStartDate =
                  DateFormat('dd/MM/yyyy').format(startDate);

              // Handle optional end date
              String? formattedEndDate;
              if (medicationData['endDate'] != null) {
                DateTime endDate = DateTime.parse(medicationData['endDate']);
                formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
              }

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.medication,
                      size: 40, color: Colors.blue),
                  title: Text(
                    medicationId,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Frequency: ${medicationData['frequency']} hours'),
                      Text('Start Date: $formattedStartDate'),
                      if (formattedEndDate != null)
                        Text('End Date: $formattedEndDate'),
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
                      const PopupMenuItem(
                        value: 'medicine',
                        child: Text('Medicine'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editMedication(medicationId);
                      } else if (value == 'delete') {
                        _deleteMedication(medicationId);
                      } else if (value == 'medicine') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicationMedicinePage(
                                      medicationId: medicationId,
                                    )));
                      } else if (value == 'view') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicationDetailsPage(
                                      medicationId: medicationId,
                                    )));
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
            MaterialPageRoute(builder: (context) => MedicationForm()),
          ).then((result) {
            if (result == 'added') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Medication added successfully!')));
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
