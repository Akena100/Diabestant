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

  // fromJson method
  factory MedicationMedicine.fromJson(Map<String, dynamic> json) {
    return MedicationMedicine(
      id: json['id'],
      medicationId: json['medicationId'],
      name: json['name'] as String,
      dosage: json['dosage'] as String,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'name': name,
      'dosage': dosage,
    };
  }
}
