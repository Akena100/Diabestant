class Pill {
  final String id;
  final String name;
  final String description;
  final String strength;
  final String shape;
  final String color;
  final String manufacturer;

  Pill(
      {required this.id,
      required this.name,
      required this.description,
      required this.strength,
      required this.shape,
      required this.color,
      required this.manufacturer});

  factory Pill.toJson(Map<String, dynamic> json) {
    return Pill(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        strength: json['strength'],
        shape: json['shape'],
        color: json['color'],
        manufacturer: json['manufacturer']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'strength': strength,
      'shape': shape,
      'color': color,
      'manufacturer': manufacturer
    };
  }
}
