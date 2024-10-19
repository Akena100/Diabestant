class BloodSugar {
  final String id;
  final String userId;
  final DateTime date;
  final String status;
  final double beforeBloodSugar; // Before meal blood sugar level
  final double afterBloodSugar; // After meal blood sugar level
  final DateTime beforeTime; // Time before the meal
  final DateTime afterTime; // Time after the meal
  final String type; // Meal type (e.g., breakfast, lunch, dinner)
  final String?
      beforeMealRecommendation; // Recommendation for before meal reading (nullable)
  final String?
      afterMealRecommendation; // Recommendation for after meal reading (nullable)

  BloodSugar({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    required this.beforeBloodSugar,
    required this.afterBloodSugar,
    required this.beforeTime,
    required this.afterTime,
    required this.type,
    this.beforeMealRecommendation, // Make this field nullable
    this.afterMealRecommendation, // Make this field nullable
  });

  // fromJson method to parse JSON data safely
  factory BloodSugar.fromJson(Map<String, dynamic> json) {
    return BloodSugar(
      id: json['id'] as String? ?? '', // Provide a default value if null
      userId:
          json['userId'] as String? ?? '', // Provide a default value if null
      date: DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.now(), // Fallback to current date if null
      status: json['status'] as String? ??
          'Unknown', // Default to 'Unknown' if null
      beforeBloodSugar: (json['beforeBloodSugar'] as num?)?.toDouble() ??
          0.0, // Default to 0.0 if null
      afterBloodSugar: (json['afterBloodSugar'] as num?)?.toDouble() ??
          0.0, // Default to 0.0 if null
      beforeTime: DateTime.tryParse(json['beforeTime'] as String? ?? '') ??
          DateTime.now(), // Fallback to current time if null
      afterTime: DateTime.tryParse(json['afterTime'] as String? ?? '') ??
          DateTime.now(), // Fallback to current time if null
      type:
          json['type'] as String? ?? 'Unknown', // Default to 'Unknown' if null
      beforeMealRecommendation:
          json['beforeMealRecommendation'] as String?, // Nullable
      afterMealRecommendation:
          json['afterMealRecommendation'] as String?, // Nullable
    );
  }

  // toJson method to serialize the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'status': status,
      'beforeBloodSugar': beforeBloodSugar,
      'afterBloodSugar': afterBloodSugar,
      'beforeTime': beforeTime.toIso8601String(),
      'afterTime': afterTime.toIso8601String(),
      'type': type,
      'beforeMealRecommendation':
          beforeMealRecommendation ?? '', // Ensure it's not null
      'afterMealRecommendation':
          afterMealRecommendation ?? '', // Ensure it's not null
    };
  }
}
