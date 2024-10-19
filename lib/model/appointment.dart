class Appointment {
  String id;
  String userId; // New field for the user's ID
  String doctorName;
  DateTime appointmentDate;
  String appointmentTime; // Time in 'HH:mm' format (24-hour)
  String reason;
  String status;

  Appointment({
    required this.id,
    required this.userId, // Add userId in the constructor
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    required this.status,
  });

  // Convert JSON to Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      userId: json['userId'] as String, // Parse userId from JSON
      doctorName: json['doctorName'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
    );
  }

  // Convert Appointment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // Include userId in the JSON
      'doctorName': doctorName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'reason': reason,
      'status': status,
    };
  }
}
