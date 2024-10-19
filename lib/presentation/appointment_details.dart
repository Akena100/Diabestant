import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/appointment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format date and time

class AppointmentDetailsPage extends StatelessWidget {
  final String appointmentId;

  const AppointmentDetailsPage({Key? key, required this.appointmentId})
      : super(key: key);

  Future<Appointment> _getAppointmentDetails() async {
    // Fetch the appointment details from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .get();

    if (doc.exists) {
      return Appointment.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Appointment not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appointmentId),
        backgroundColor: Colors.teal, // Stylish app bar color
      ),
      body: FutureBuilder<Appointment>(
        future: _getAppointmentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('$appointmentId No appointment found.'));
          }

          Appointment appointment = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Doctor and appointment info card
                _buildAppointmentInfoCard(appointment),

                const SizedBox(height: 20),

                // Reason for appointment
                _buildAppointmentReason(appointment),

                const SizedBox(height: 20),

                // Appointment Status section
                _buildAppointmentStatus(appointment),

                // Add some medical-related graphic/illustration below the details
                const SizedBox(height: 40),
                _buildMedicalIllustration(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build appointment info card (doctor, date, time)
  Widget _buildAppointmentInfoCard(Appointment appointment) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(appointment.doctorName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Doctor'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: Text(
                DateFormat.yMMMd().format(appointment.appointmentDate),
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: const Text('Date'),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.teal),
              title: Text(
                appointment.appointmentTime,
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: const Text('Time'),
            ),
          ],
        ),
      ),
    );
  }

  // Build reason for appointment section
  Widget _buildAppointmentReason(Appointment appointment) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.teal, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appointment.reason,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build appointment status section
  Widget _buildAppointmentStatus(Appointment appointment) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.assignment_turned_in,
                color: Colors.teal, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appointment.status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appointment.status == 'Confirmed'
                      ? Colors.green
                      : appointment.status == 'Cancelled'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build medical-related illustration/graphic
  Widget _buildMedicalIllustration() {
    return Center(
      child: Image.asset(
        'assets/logo-db.png', // Ensure you have this asset or use any relevant image
        height: 150,
      ),
    );
  }
}
