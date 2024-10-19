import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationDetailsPage extends StatelessWidget {
  final String medicationId;

  MedicationDetailsPage({required this.medicationId});

  Future<Map<String, dynamic>?> _getMedicationDetails() async {
    final medicationSnapshot = await FirebaseFirestore.instance
        .collection('medications')
        .doc(medicationId)
        .get();

    if (medicationSnapshot.exists) {
      final medicineSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .collection('medication_medicines')
          .get();

      List<Map<String, dynamic>> medicines =
          medicineSnapshot.docs.map((doc) => doc.data()).toList();

      return {
        ...medicationSnapshot.data()!,
        'medicines': medicines,
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getMedicationDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading data.'));
          }

          final medicationData = snapshot.data!;
          final List medicines = medicationData['medicines'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication Information Card
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medication Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                            'Frequency:', medicationData['frequency']),
                        _buildDetailRow(
                          'Start Date:',
                          DateTime.parse(medicationData['startDate'])
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                        if (medicationData['endDate'] != null)
                          _buildDetailRow(
                            'End Date:',
                            DateTime.parse(medicationData['endDate'])
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                      ],
                    ),
                  ),
                ),

                // Medication Medicines Section
                const Text(
                  'Medicines',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                ...medicines.map((medicine) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        medicine['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Dosage: ${medicine['dosage']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.medical_services,
                          color: Colors.green),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
