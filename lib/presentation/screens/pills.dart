import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/medicine.dart';
import 'package:flutter/material.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/model/medication_medicine.dart';
import 'package:intl/intl.dart'; // For formatting DateTime

class PillsPage extends StatefulWidget {
  final String x; // medicationId
  const PillsPage({super.key, required this.x});

  @override
  _PillsPageState createState() => _PillsPageState();
}

class _PillsPageState extends State<PillsPage> {
  DateTime? _selectedDate;
  String? _selectedPill;
  int _pillCount = 0;
  int _selectedIndex = 0;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _incrementPillCount() {
    setState(() {
      _pillCount++;
    });
  }

  void _decrementPillCount() {
    if (_pillCount > 0) {
      setState(() {
        _pillCount--;
      });
    }
  }

  // Method to retrieve medicines from Firestore where medicationId = widget.x
  Stream<List<MedicationMedicine>> fetchMedicines() {
    return FirebaseFirestore.instance
        .collection('medications')
        .doc(widget.x)
        .collection('medication_medicines')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return MedicationMedicine.fromJson(doc.data());
            }).toList());
  }

  Future<void> saveMedication() async {
    if (_selectedDate != null && _selectedPill != null && _pillCount > 0) {
      final medicateId = widget.x; // Use medicationId as medicateId

      // Creating the Medicate object
      final medicate = Medicate(
        id: DateTime.now()
            .millisecondsSinceEpoch, // Unique ID based on timestamp
        medicateId: medicateId,
        name: _selectedPill!, // Pill name
        date: _selectedDate!, // Selected date
        numberOfPills: _pillCount, // Selected pill count
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('medicates')
          .add(medicate.toJson());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication saved successfully!')),
      );

      // Reset fields after saving
      setState(() {
        _selectedDate = null;
        _selectedPill = null;
        _pillCount = 0;
      });
    } else {
      // Show error message if fields are not properly selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields before saving.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            const Text('Pills', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Dropdown for selecting pill name
            StreamBuilder<List<MedicationMedicine>>(
              stream: fetchMedicines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Error fetching medicines');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No medicines available');
                } else {
                  final medicines = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pill Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    value: _selectedPill,
                    items: medicines.map((medicine) {
                      return DropdownMenuItem<String>(
                        value: medicine.name,
                        child: Text(medicine.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPill = value;
                      });
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _decrementPillCount,
                    child: CircleAvatar(
                      radius: 16.0,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.remove, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text('$_pillCount Pill(s)',
                      style: const TextStyle(fontSize: 16.0)),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: _incrementPillCount,
                    child: CircleAvatar(
                      radius: 16.0,
                      backgroundColor: Colors.green.shade200,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveMedication, // Save the medication details
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
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
