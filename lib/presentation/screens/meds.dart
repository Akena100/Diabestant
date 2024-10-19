
import 'package:diabestant/model/medicine.dart';
import 'package:diabestant/presentation/screens/pills.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationMedicinePage extends StatelessWidget {
  final String medicationId;

  const MedicationMedicinePage({Key? key, required this.medicationId})
      : super(key: key);

  // Method to retrieve data from Firestore filtered by medicationId
  Stream<List<Medicate>> fetchMedicationMedicines() {
    return FirebaseFirestore.instance
        .collection('medicates')
        .where('medicateId', isEqualTo: medicationId) // Filter by medicationId
        .snapshots()
        .map((snapshot) {
      // Log if no documents are found
      if (snapshot.docs.isEmpty) {
        print('No documents found for medicationId: $medicationId');
      }
      // Log each document data
      return snapshot.docs.map((doc) {
        print('Document data: ${doc.data()}'); // Log each document
        return Medicate.fromJson(doc.data());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Medicate>>(
          stream: fetchMedicationMedicines(),
          builder: (context, snapshot) {
            // Loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              );
            }
            // Error handling
            else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error fetching data',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            // Handling no data case
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No medications available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            // Displaying the data
            else {
              final medicines = snapshot.data!;
              return ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        leading: const Icon(
                          Icons.medical_services,
                          color: Colors.teal,
                        ),
                        title: Text(
                          medicine.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Date: ${medicine.date}\n'
                          'Pills: ${medicine.numberOfPills
                          }',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: () {
                            // Logic to edit medication if needed
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => PillsPage(
                        x: medicationId, // Pass the medicationId to PillsPage
                      ))));
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
