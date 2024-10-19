class Diabetes {
  final String id;
  final String name;
  Diabetes({required this.id, required this.name});

  factory Diabetes.fromJson(Map<String, dynamic> json) {
    return Diabetes(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
