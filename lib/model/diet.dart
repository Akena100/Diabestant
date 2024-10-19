class DietPlan {
  final String dietPlanID;
  final String patientID;
  final DateTime dateCreated;
  final Map<String, String> meals;
  final int calorieIntake;
  final int carbohydrateCount;
  final int proteinIntake;
  final int fatIntake;
  final String recommendedBy;

  DietPlan({
    required this.dietPlanID,
    required this.patientID,
    required this.dateCreated,
    required this.meals,
    required this.calorieIntake,
    required this.carbohydrateCount,
    required this.proteinIntake,
    required this.fatIntake,
    required this.recommendedBy,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      dietPlanID: json['dietPlanID'],
      patientID: json['patientID'],
      dateCreated: DateTime.parse(json['dateCreated']),
      meals: Map<String, String>.from(json['meals']),
      calorieIntake: json['calorieIntake'],
      carbohydrateCount: json['carbohydrateCount'],
      proteinIntake: json['proteinIntake'],
      fatIntake: json['fatIntake'],
      recommendedBy: json['recommendedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dietPlanID': dietPlanID,
      'patientID': patientID,
      'dateCreated': dateCreated.toIso8601String(),
      'meals': meals,
      'calorieIntake': calorieIntake,
      'carbohydrateCount': carbohydrateCount,
      'proteinIntake': proteinIntake,
      'fatIntake': fatIntake,
      'recommendedBy': recommendedBy,
    };
  }
}
