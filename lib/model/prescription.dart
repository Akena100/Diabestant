class Prescription {
  final String prescriptionID;
  final String patientID;
  final String doctorID;
  final DateTime datePrescribed;
  final List<Map<String, dynamic>> medications;
  final String notes;

  Prescription({
    required this.prescriptionID,
    required this.patientID,
    required this.doctorID,
    required this.datePrescribed,
    required this.medications,
    required this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionID: json['prescriptionID'],
      patientID: json['patientID'],
      doctorID: json['doctorID'],
      datePrescribed: DateTime.parse(json['datePrescribed']),
      medications: List<Map<String, dynamic>>.from(json['medications']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionID': prescriptionID,
      'patientID': patientID,
      'doctorID': doctorID,
      'datePrescribed': datePrescribed.toIso8601String(),
      'medications': medications,
      'notes': notes,
    };
  }
}
