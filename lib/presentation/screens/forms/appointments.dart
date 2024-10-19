import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:uuid/uuid.dart';

class AppointmentForm extends StatefulWidget {
  final String? appointmentId; // ID of the appointment to edit (if any)
  final Map<String, dynamic>?
      appointmentData; // Existing appointment data (if any)

  AppointmentForm({this.appointmentId, this.appointmentData});

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  String _status = 'Pending'; // Default status

  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();

    // Populate fields if editing an existing appointment
    if (widget.appointmentData != null) {
      doctorNameController.text = widget.appointmentData!['doctorName'] ?? '';
      reasonController.text = widget.appointmentData!['reason'] ?? '';
      _status = widget.appointmentData!['status'] ?? 'Pending';
      _appointmentDate = DateFormat('yyyy-MM-dd')
          .parse(widget.appointmentData!['appointmentDate']);
      _appointmentTime = TimeOfDay(
        hour:
            int.parse(widget.appointmentData!['appointmentTime'].split(':')[0]),
        minute:
            int.parse(widget.appointmentData!['appointmentTime'].split(':')[1]),
      );
    }
  }

  // Function to pick appointment date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _appointmentDate = pickedDate;
      });
    }
  }

  // Function to pick appointment time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _appointmentTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _appointmentTime = pickedTime;
      });
    }
  }

  // Function to schedule notifications
  static Future<void> scheduleNotification(
      DateTime scheduledTime, String doctorName, String id) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),
        payload: {'appointmentId': id},
        channelKey: 'appointments',
        title: 'Appointment Reminder',
        body:
            'You have an appointment with Dr. $doctorName at ${DateFormat.Hm().format(scheduledTime)}.',
      ),
      schedule: NotificationCalendar(
        year: scheduledTime.year,
        month: scheduledTime.month,
        day: scheduledTime.day,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
        second: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
      actionButtons: [
        NotificationActionButton(key: 'REDIRECT', label: 'View Details'),
        NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction),
      ],
    );
    print(
        'Scheduling notification with appointmentIdfffffffffffffffffffffffffffffffffffffffffffffffffffffff: $id');
  }

  // Function to save data to Firestore
  void _saveAppointment() async {
    if (_formKey.currentState!.validate() &&
        _appointmentDate != null &&
        _appointmentTime != null) {
      final DateTime appointmentDateTime = DateTime(
        _appointmentDate!.year,
        _appointmentDate!.month,
        _appointmentDate!.day,
        _appointmentTime!.hour,
        _appointmentTime!.minute,
      );

      final appointmentTime = DateFormat.Hm().format(appointmentDateTime);
      final id = const Uuid().v4();
      User user = FirebaseAuth.instance.currentUser!;

      // Create appointment data
      Map<String, dynamic> appointmentData = {
        'id': id,
        'userId': user.uid,
        'doctorName': doctorNameController.text,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(_appointmentDate!),
        'appointmentTime': appointmentTime,
        'reason': reasonController.text,
        'status': _status,
      };
      Map<String, dynamic> appointmentData2 = {
        'doctorName': doctorNameController.text,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(_appointmentDate!),
        'appointmentTime': appointmentTime,
        'reason': reasonController.text,
        'status': _status,
      };

      // Check if editing or creating a new appointment
      if (widget.appointmentId != null) {
        // Update existing appointment
        await _firestore
            .collection('appointments')
            .doc(widget.appointmentId)
            .update(appointmentData2);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Appointment Updated')));
      } else {
        // Save new appointment
        await _firestore.collection('appointments').add(appointmentData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Appointment Saved')));
      }

      // Schedule notification
      await scheduleNotification(
          appointmentDateTime, doctorNameController.text, id);
      _formKey.currentState!.reset();
      setState(() {
        _appointmentDate = null;
        _appointmentTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
    }
    Navigator.pop(context);
  }

  void requestNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointmentId != null
            ? 'Edit Appointment'
            : 'New Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 30.0), // Added margins
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16), // Spacing between fields
              // Doctor Name
              TextFormField(
                controller: doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter doctor name';
                  return null;
                },
              ),
              const SizedBox(height: 20), // Increased spacing

              // Appointment Date Picker
              Card(
                margin:
                    const EdgeInsets.only(bottom: 20), // Margin for the card
                child: ListTile(
                  title: Text(_appointmentDate == null
                      ? 'Pick Appointment Date'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(_appointmentDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
              ),

              // Appointment Time Picker
              Card(
                margin:
                    const EdgeInsets.only(bottom: 20), // Margin for the card
                child: ListTile(
                  title: Text(_appointmentTime == null
                      ? 'Pick Appointment Time'
                      : 'Time: ${_appointmentTime!.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
              ),

              // Reason for Appointment
              TextFormField(
                controller: reasonController,
                maxLines: 3, // Allow multiple lines
                decoration: const InputDecoration(
                  labelText: 'Reason for Appointment',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter reason for appointment';
                  return null;
                },
              ),
              const SizedBox(height: 20), // Increased spacing

              // Appointment Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Appointment Status',
                  border: OutlineInputBorder(),
                ),
                items: ['Pending', 'Confirmed', 'Cancelled'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 20), // Increased spacing

              // Save Button
              ElevatedButton(
                onPressed: _saveAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(widget.appointmentId != null
                    ? 'Update Appointment'
                    : 'Save Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
