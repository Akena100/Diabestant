import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MedicationForm extends StatefulWidget {
  final String?
      medicationId; // If null, it's a new medication; otherwise, editing existing
  MedicationForm({this.medicationId});

  @override
  _MedicationFormState createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _medicationId;

  List<MedicationMedicine> _medicationsList = [];

  @override
  void initState() {
    super.initState();
    if (widget.medicationId != null) {
      _loadExistingMedication(widget.medicationId!);
    } else {
      _medicationId =
          const Uuid().v4(); // Generate new ID if creating new medication
    }
  }

  // Load existing medication from Firestore
  Future<void> _loadExistingMedication(String medicationId) async {
    final medicationSnapshot = await FirebaseFirestore.instance
        .collection('medications')
        .doc(medicationId)
        .get();

    if (medicationSnapshot.exists) {
      final data = medicationSnapshot.data()!;
      setState(() {
        _frequencyController.text = data['frequency'] ?? '';
        _startDate = DateTime.parse(data['startDate']);
        _endDate =
            data['endDate'] != null ? DateTime.parse(data['endDate']) : null;
        _medicationId = medicationId;
      });

      final medsSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .collection('medication_medicines')
          .get();

      setState(() {
        _medicationsList = medsSnapshot.docs
            .map((doc) => MedicationMedicine.fromJson(doc.data()))
            .toList();
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate() && _startDate != null) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user is signed in.')),
          );
          return;
        }

        final medicationData = {
          'medicationID': _medicationId!,
          'userId': currentUser.uid,
          'frequency': _frequencyController.text,
          'startDate': _startDate!.toIso8601String(),
          'endDate': _endDate?.toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('medications')
            .doc(_medicationId)
            .set(medicationData);

        // Set notification using Awesome Notifications
        _setNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medication: $e')),
        );
      }
      Navigator.pop(context);
    }
  }

  void _setNotifications() {
    int frequencyInSeconds = int.tryParse(_frequencyController.text) ?? 0;

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(10000),
        channelKey: 'medication',
        title: 'Time for your medication',
        payload: {'medicationId': _medicationId},
        body: 'It\'s time to take your medicine!',
      ),
      schedule: NotificationInterval(
        interval: frequencyInSeconds,
        timeZone: DateTime.now().timeZoneName,
        repeats: true,
      ),
    );
  }

  Future<void> _addMedicationMedicine() async {
    if (_medicineNameController.text.isNotEmpty &&
        _dosageController.text.isNotEmpty) {
      final newMed = MedicationMedicine(
        id: const Uuid().v4(),
        medicationId: _medicationId!,
        name: _medicineNameController.text,
        dosage: _dosageController.text,
      );

      setState(() {
        _medicationsList.add(newMed);
      });

      await FirebaseFirestore.instance
          .collection('medications')
          .doc(_medicationId)
          .collection('medication_medicines')
          .doc(newMed.id)
          .set(newMed.toJson());

      _medicineNameController.clear();
      _dosageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in both medicine name and dosage')),
      );
    }
  }

  Future<void> _deleteMedicationMedicine(String id) async {
    await FirebaseFirestore.instance
        .collection('medications')
        .doc(_medicationId)
        .collection('medication_medicines')
        .doc(id)
        .delete();

    setState(() {
      _medicationsList.removeWhere((med) => med.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medication medicine deleted!')),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medicationId != null ? 'Edit Medication' : 'Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _frequencyController,
                decoration:
                    const InputDecoration(labelText: 'Frequency (in seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter frequency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${_startDate!.toLocal()}',
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Select End Date (Optional)'
                      : 'End Date: ${_endDate!.toLocal()}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 20),
              const Text('Medication Medicines'),
              const SizedBox(height: 10),
              ..._medicationsList.map((med) => ListTile(
                    title: Text('${med.name} (${med.dosage})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteMedicationMedicine(med.id),
                    ),
                  )),
              const SizedBox(height: 20),
              TextFormField(
                controller: _medicineNameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addMedicationMedicine,
                child: const Text('Add Medication Medicine'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMedication,
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MedicationMedicine class (unchanged)
class MedicationMedicine {
  final String id;
  final String medicationId;
  final String name;
  final String dosage;

  MedicationMedicine({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.dosage,
  });

  factory MedicationMedicine.fromJson(Map<String, dynamic> json) {
    return MedicationMedicine(
      id: json['id'],
      medicationId: json['medicationId'],
      name: json['name'],
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'name': name,
      'dosage': dosage,
    };
  }
}
