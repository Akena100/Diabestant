class Medication {
  final String medicationID;
  final String userId;

  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;

  Medication({
    required this.medicationID,
    required this.userId,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      medicationID: json['medicationID'],
      userId: json['userId'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationID': medicationID,
      'userId': userId,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}
