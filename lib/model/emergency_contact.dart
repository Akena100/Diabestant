class EmergencyContact {
  final String contactID;
  final String patientID;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String email;
  final String address;

  EmergencyContact({
    required this.contactID,
    required this.patientID,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      contactID: json['contactID'],
      patientID: json['patientID'],
      name: json['name'],
      relationship: json['relationship'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactID': contactID,
      'patientID': patientID,
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}
