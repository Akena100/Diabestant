import 'package:cloud_firestore/cloud_firestore.dart';

class Medicate {
  final int id;
  final String medicateId;
  final String name;
  final DateTime date;
  final int numberOfPills;

  Medicate({
    required this.id,
    required this.medicateId,
    required this.name,
    required this.date,
    required this.numberOfPills,
  });

  // fromJson method
  factory Medicate.fromJson(Map<String, dynamic> json) {
    return Medicate(
      id: json['id'] as int,
      medicateId: json['medicateId'] as String,
      name: json['name'] as String,
      date: (json['date'] as Timestamp)
          .toDate(), // Assuming Firestore Timestamp is used
      numberOfPills: json['numberOfPills'] as int,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicateId': medicateId,
      'name': name,
      'date': date,
      'numberOfPills': numberOfPills,
    };
  }
}
