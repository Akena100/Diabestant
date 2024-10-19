import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting DateTime

class BloodSugarDetailsPage extends StatefulWidget {
  final String bloodSugarId;

  const BloodSugarDetailsPage({Key? key, required this.bloodSugarId})
      : super(key: key);

  @override
  _BloodSugarDetailsPageState createState() => _BloodSugarDetailsPageState();
}

class _BloodSugarDetailsPageState extends State<BloodSugarDetailsPage> {
  BloodSugar? bloodSugar;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBloodSugarDetails();
  }

  void fetchBloodSugarDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bloodSugarLogs')
          .doc(widget.bloodSugarId)
          .get();

      if (doc.exists) {
        setState(() {
          bloodSugar = BloodSugar.fromJson(doc.data() as Map<String, dynamic>);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Sugar Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bloodSugar == null
              ? const Center(child: Text('No blood sugar data found.'))
              : _buildDetailsView(),
    );
  }

  Widget _buildDetailsView() {
    // Format DateTime
    String formatDate(DateTime date) =>
        DateFormat('MMM dd, yyyy h:mm a').format(date);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("General Info"),
            _buildInfoCard([
              _buildDetailRow("Date:", formatDate(bloodSugar!.date)),
              _buildDetailRow("Meal Type:", bloodSugar!.type),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader("Before Meal"),
            _buildInfoCard([
              _buildDetailRow("Blood Sugar Level:",
                  "${bloodSugar!.beforeBloodSugar} mmol/L"),
              _buildDetailRow("Time:", formatDate(bloodSugar!.beforeTime)),
              _buildDetailRow("Recommendation:", ''),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  bloodSugar!.beforeMealRecommendation!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader("After Meal"),
            _buildInfoCard([
              _buildDetailRow("Blood Sugar Level:",
                  "${bloodSugar!.afterBloodSugar} mmol/L"),
              _buildDetailRow("Time:", formatDate(bloodSugar!.afterTime)),
              _buildDetailRow("Recommendation:", ''),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  bloodSugar!.afterMealRecommendation!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Other sections can be added here
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
