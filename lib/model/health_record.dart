class HealthRecord {
  final String recordID;
  final String patientID;
  final DateTime recordDate;
  final String recordType;
  final String description;
  final String recordedBy;

  HealthRecord({
    required this.recordID,
    required this.patientID,
    required this.recordDate,
    required this.recordType,
    required this.description,
    required this.recordedBy,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      recordID: json['recordID'],
      patientID: json['patientID'],
      recordDate: DateTime.parse(json['recordDate']),
      recordType: json['recordType'],
      description: json['description'],
      recordedBy: json['recordedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordID': recordID,
      'patientID': patientID,
      'recordDate': recordDate.toIso8601String(),
      'recordType': recordType,
      'description': description,
      'recordedBy': recordedBy,
    };
  }
}
