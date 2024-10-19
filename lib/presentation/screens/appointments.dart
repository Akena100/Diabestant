import 'package:diabestant/presentation/appointment_details.dart';
import 'package:diabestant/presentation/screens/forms/appointments.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/presentation/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your AppointmentForm here
import 'package:animated_text_kit/animated_text_kit.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  AppointmentsPageState createState() => AppointmentsPageState();
}

class AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _appointmentsStream;
  int _selectedIndex = 0;
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _appointmentsStream = _firestore
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  // Function to delete an appointment
  Future<void> _deleteAppointment(String id) async {
    await _firestore.collection('appointments').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully')));
  }

  // Function to navigate to the appointment form for editing
  void _editAppointment(String id, Map<String, dynamic> appointmentData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentForm(
          appointmentId: id,
          appointmentData: appointmentData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentsStream,
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
                    'No Appointments Found!',
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
              var appointmentData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var appointmentId = snapshot.data!.docs[index].id;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      size: 40, color: Colors.blue),
                  title: Text(
                    appointmentData['doctorName'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${appointmentData['appointmentDate']}'),
                      Text('Time: ${appointmentData['appointmentTime']}'),
                      Text('Reason: ${appointmentData['reason']}'),
                      Text('Status: ${appointmentData['status']}'),
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
                        _editAppointment(appointmentId, appointmentData);
                      } else if (value == 'delete') {
                        _deleteAppointment(appointmentId);
                      } else if (value == 'view') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AppointmentDetailsPage(
                                    appointmentId: appointmentId)));
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
            MaterialPageRoute(builder: (context) => AppointmentForm()),
          ).then((result) {
            if (result == 'added') {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointment added successfully!')));
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
