import 'package:flutter/material.dart';

class BasicDetailsPage extends StatefulWidget {
  @override
  _BasicDetailsPageState createState() => _BasicDetailsPageState();
}

class _BasicDetailsPageState extends State<BasicDetailsPage> {
  String? selectedGender = 'Male';
  String? selectedDiabetesType = 'Monogenic diabetes';
  String? selectedTherapy;
  String? selectedMeasurementUnit;
  String? selectedWeight;
  String? selectedAge;
  String? sugarGoal;
  String? glucoseLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic details'),
      ),
      body: SingleChildScrollView(
        // Add SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your individual parameters are important for Dia for in-depth personalization.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              buildDropdown(
                  'Your gender', selectedGender, ['Male', 'Female', 'Other'],
                  (value) {
                setState(() {
                  selectedGender = value;
                });
              }),
              buildButton('Your weight', selectedWeight, 'Select weight', () {
                // Add functionality to select weight
              }),
              buildButton('Your age', selectedAge, 'Select', () {
                // Add functionality to select age
              }),
              buildDropdown('Your diabetes type', selectedDiabetesType,
                  ['Type 1', 'Type 2', 'Monogenic diabetes'], (value) {
                setState(() {
                  selectedDiabetesType = value;
                });
              }),
              buildButton('Your therapy', selectedTherapy, 'Select therapy',
                  () {
                // Add functionality to select therapy
              }),
              buildButton('Your measurement unit', selectedMeasurementUnit,
                  'Select unit', () {
                // Add functionality to select measurement unit
              }),
              buildTextField('Your sugar goal', sugarGoal, (value) {
                setState(() {
                  sugarGoal = value;
                });
              }),
              buildTextField('Your glucose level', glucoseLevel, (value) {
                setState(() {
                  glucoseLevel = value;
                });
              }),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add confirm functionality
                  },
                  child: Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
      ),
    );
  }

  Widget buildButton(
      String label, String? value, String defaultValue, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          child: Text(value ?? defaultValue),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
