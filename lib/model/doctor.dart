class Doctor {
  final String doctorID;
  final String firstName;
  final String lastName;
  final String specialization;
  final String contactNumber;
  final String email;
  final String hospital;

  Doctor({
    required this.doctorID,
    required this.firstName,
    required this.lastName,
    required this.specialization,
    required this.contactNumber,
    required this.email,
    required this.hospital,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorID: json['doctorID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      specialization: json['specialization'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      hospital: json['hospital'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorID': doctorID,
      'firstName': firstName,
      'lastName': lastName,
      'specialization': specialization,
      'contactNumber': contactNumber,
      'email': email,
      'hospital': hospital,
    };
  }
}
