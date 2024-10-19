class Patient {
  final String patientID;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String contactNumber;
  final String email;
  final String address;
  final String emergencyContact;
  final DateTime dateOfDiagnosis;
  final String diabetesType;
  final String primaryDoctor;

  Patient({
    required this.patientID,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.emergencyContact,
    required this.dateOfDiagnosis,
    required this.diabetesType,
    required this.primaryDoctor,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientID: json['patientID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      dateOfDiagnosis: DateTime.parse(json['dateOfDiagnosis']),
      diabetesType: json['diabetesType'],
      primaryDoctor: json['primaryDoctor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientID': patientID,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'dateOfDiagnosis': dateOfDiagnosis.toIso8601String(),
      'diabetesType': diabetesType,
      'primaryDoctor': primaryDoctor,
    };
  }
}
