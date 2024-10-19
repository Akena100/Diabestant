class ExercisePlan {
  final String exercisePlanID;
  final String patientID;
  final DateTime dateCreated;
  final String exerciseType;
  final int duration;
  final String frequency;
  final String intensity;
  final String recommendedBy;

  ExercisePlan({
    required this.exercisePlanID,
    required this.patientID,
    required this.dateCreated,
    required this.exerciseType,
    required this.duration,
    required this.frequency,
    required this.intensity,
    required this.recommendedBy,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      exercisePlanID: json['exercisePlanID'],
      patientID: json['patientID'],
      dateCreated: DateTime.parse(json['dateCreated']),
      exerciseType: json['exerciseType'],
      duration: json['duration'],
      frequency: json['frequency'],
      intensity: json['intensity'],
      recommendedBy: json['recommendedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercisePlanID': exercisePlanID,
      'patientID': patientID,
      'dateCreated': dateCreated.toIso8601String(),
      'exerciseType': exerciseType,
      'duration': duration,
      'frequency': frequency,
      'intensity': intensity,
      'recommendedBy': recommendedBy,
    };
  }
}
