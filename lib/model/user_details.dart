class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String gender;
  final String? weight;
  final String? age;
  final String diabetesType;
  final String? sugarGoal;
  final String? glucoseLevel;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.gender,
    this.weight,
    this.age,
    required this.diabetesType,
    this.sugarGoal,
    this.glucoseLevel,
  });

  // Convert a Firestore document to an AppUser object
  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ??
          'Patient', // default to 'Patient' if no role is provided
      gender: data['gender'] ?? '',
      weight: data['weight'],
      age: data['age'],
      diabetesType: data['diabetesType'] ??
          'Type 1', // default to 'Type 1' if not provided
      sugarGoal: data['sugarGoal'],
      glucoseLevel: data['glucoseLevel'],
    );
  }

  // Convert an AppUser object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'gender': gender,
      'weight': weight,
      'age': age,
      'diabetesType': diabetesType,
      'sugarGoal': sugarGoal,
      'glucoseLevel': glucoseLevel,
    };
  }
}
