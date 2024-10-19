class LabTest {
  final String labTestID;
  final String patientID;
  final DateTime testDate;
  final String testType;
  final String result;
  final String normalRange;
  final String abnormalFlag;
  final String conductedBy;

  LabTest({
    required this.labTestID,
    required this.patientID,
    required this.testDate,
    required this.testType,
    required this.result,
    required this.normalRange,
    required this.abnormalFlag,
    required this.conductedBy,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      labTestID: json['labTestID'],
      patientID: json['patientID'],
      testDate: DateTime.parse(json['testDate']),
      testType: json['testType'],
      result: json['result'],
      normalRange: json['normalRange'],
      abnormalFlag: json['abnormalFlag'],
      conductedBy: json['conductedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labTestID': labTestID,
      'patientID': patientID,
      'testDate': testDate.toIso8601String(),
      'testType': testType,
      'result': result,
      'normalRange': normalRange,
      'abnormalFlag': abnormalFlag,
      'conductedBy': conductedBy,
    };
  }
}
