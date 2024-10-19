class Food {
  final String id;
  final String name;
  final String category;
  final double servingSize;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fats;
  final double sugar;
  final String image;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
    required this.sugar,
    required this.image,
  });

  // From JSON
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      servingSize: (json['servingSize'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      image: json['image'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'sugar': sugar,
      'image': image,
    };
  }
}
