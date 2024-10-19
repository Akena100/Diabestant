import 'package:diabestant/model/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:diabestant/presentation/widgets/show.dart';
import 'package:diabestant/presentation/widgets/show2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for user ID handling

class BloodSugarLogForm extends StatefulWidget {
  final String? logId;
  final Map<String, dynamic>? bloodSugarLogData;

  const BloodSugarLogForm({Key? key, this.logId, this.bloodSugarLogData})
      : super(key: key);

  @override
  _BloodSugarLogFormState createState() => _BloodSugarLogFormState();
}

class _BloodSugarLogFormState extends State<BloodSugarLogForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  late TextEditingController _beforeBloodSugarController;
  late TextEditingController _afterBloodSugarController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedBeforeTime;
  TimeOfDay? _selectedAfterTime;
  User? user = FirebaseAuth.instance.currentUser!;

  // Meal type options
  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Recommended',
    'Random'
  ];
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _beforeBloodSugarController = TextEditingController(
      text: widget.bloodSugarLogData?['beforeBloodSugar']?.toString() ?? '',
    );
    _afterBloodSugarController = TextEditingController(
      text: widget.bloodSugarLogData?['afterBloodSugar']?.toString() ?? '',
    );

    if (widget.bloodSugarLogData != null) {
      _selectedDate = DateTime.parse(widget.bloodSugarLogData!['date']);
      _selectedBeforeTime = TimeOfDay.fromDateTime(
          DateTime.parse(widget.bloodSugarLogData!['beforeTime']));
      _selectedAfterTime = TimeOfDay.fromDateTime(
          DateTime.parse(widget.bloodSugarLogData!['afterTime']));
      _selectedMealType = widget.bloodSugarLogData?['type'] ?? 'Breakfast';
    }
  }

  @override
  void dispose() {
    _beforeBloodSugarController.dispose();
    _afterBloodSugarController.dispose();
    super.dispose();
  }

  Future<bool> _checkMealTypeExists(String mealType) async {
    if (_selectedDate == null) return false;

    final querySnapshot = await _firestore
        .collection('bloodSugarLogs')
        .where('date', isEqualTo: _selectedDate!.toIso8601String())
        .where('userId', isEqualTo: user!.uid)
        .where('type', isEqualTo: mealType)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _saveBloodSugarLog() async {
    if (_formKey.currentState!.validate()) {
      _selectedDate ??= DateTime.now();
      _selectedBeforeTime ??= const TimeOfDay(hour: 0, minute: 0);
      _selectedAfterTime ??= const TimeOfDay(hour: 0, minute: 0);

      final beforeTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedBeforeTime!.hour,
        _selectedBeforeTime!.minute,
      );

      double before = double.parse(_beforeBloodSugarController.text);
      double after = _afterBloodSugarController.text.isNotEmpty
          ? double.parse(_afterBloodSugarController.text)
          : 0.0;

      final afterTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedAfterTime!.hour,
        _selectedAfterTime!.minute,
      );

      final exists = await _checkMealTypeExists(_selectedMealType!);

      if (exists && widget.logId == null) {
        _showErrorDialog('Meal already exists for today');
        return;
      }

      final bloodSugarLog = BloodSugar(
        id: widget.logId ?? _firestore.collection('bloodSugarLogs').doc().id,
        userId: _auth.currentUser?.uid ?? 'unknown_user', // Dynamic user ID
        date: _selectedDate!,
        status: 'Normal',
        beforeBloodSugar: before,
        afterBloodSugar: after,
        beforeTime: beforeTime,
        afterTime: afterTime,
        type: _selectedMealType!, beforeMealRecommendation: '',
        afterMealRecommendation: '',
      );

      await _firestore
          .collection('bloodSugarLogs')
          .doc(widget.logId)
          .set(bloodSugarLog.toJson(), SetOptions(merge: true));

      Navigator.pop(context, 'added');
      _showAppropriateDialog(bloodSugarLog);
      if (before > 0 && after == 0) {}
    }
  }

  void _showAppropriateDialog(BloodSugar bloodSugarLog) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Image.asset(
              'assets/diabot.png',
              height: 150,
              width: 100,
            )),
            content: bloodSugarLog.beforeBloodSugar > 0 &&
                    bloodSugarLog.afterBloodSugar == 0
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Show(bloodSugar: bloodSugarLog))
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Show2(bloodSugar: bloodSugarLog),
                  ),
          );
        });
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context, bool isBefore) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: isBefore
          ? (_selectedBeforeTime ?? TimeOfDay.now())
          : (_selectedAfterTime ?? TimeOfDay.now()),
    );

    if (time != null) {
      setState(() {
        if (isBefore) {
          _selectedBeforeTime = time;
        } else {
          _selectedAfterTime = time;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logId != null
            ? 'Edit Blood Sugar Log'
            : 'Add Blood Sugar Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: const Text('Select Date'),
                subtitle: Text(
                  _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : 'No date selected',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: _mealTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMealType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a meal type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _beforeBloodSugarController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Before Blood Sugar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your blood sugar level';
                  }
                  if (double.parse(value) > 15 || double.parse(value) < 2) {
                    return 'Value is between 2 - 15';
                  }
                  return null;
                },
              ),
              ListTile(
                title: const Text('Before Meal Time'),
                subtitle: Text(
                  _selectedBeforeTime != null
                      ? _selectedBeforeTime!.format(context)
                      : 'No time selected',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, true),
              ),
              TextFormField(
                controller: _afterBloodSugarController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'After Blood Sugar'),
              ),
              ListTile(
                title: const Text('After Meal Time'),
                subtitle: Text(
                  _selectedAfterTime != null
                      ? _selectedAfterTime!.format(context)
                      : 'No time selected',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, false),
              ),
              ElevatedButton(
                onPressed: _saveBloodSugarLog,
                child: const Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
