import 'package:diabestant/model/medication_medicine.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddMedicationMedicinePage extends StatefulWidget {
  const AddMedicationMedicinePage({Key? key}) : super(key: key);

  @override
  _AddMedicationMedicinePageState createState() =>
      _AddMedicationMedicinePageState();
}

class _AddMedicationMedicinePageState extends State<AddMedicationMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _medicationIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  // Method to add data to Firestore
  Future<void> _addMedicationMedicine() async {
    if (_formKey.currentState!.validate()) {
      final medicationMedicine = MedicationMedicine(
        id: const Uuid().v4(),
        medicationId: '',
        name: _nameController.text,
        dosage: _dosageController.text,
      );

      try {
        await FirebaseFirestore.instance
            .collection('medication_medicines')
            .add(medicationMedicine.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Medication Medicine added successfully')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding data: $e')),
        );
      }
    }
  }

  // Clear the form fields after successful submission
  void _clearForm() {
    _idController.clear();
    _medicationIdController.clear();
    _nameController.clear();
    _dosageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ID Field

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dosage Field
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _addMedicationMedicine,
                child: const Text('Add Medication Medicine'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _medicationIdController.dispose();
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}
