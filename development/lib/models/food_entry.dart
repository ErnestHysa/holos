/// Food entry model for nutrition tracking
class FoodEntry {
  final String id;
  final String userId;
  final String name;
  final String? emoji;
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final DateTime timestamp;
  final String? mealType; // breakfast, lunch, dinner, snack
  final String? source; // manual, barcode, ai_suggestion
  final int? servingSize; // 1 = single serving

  FoodEntry({
    required this.id,
    required this.userId,
    required this.name,
    this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
    this.mealType,
    this.source,
    this.servingSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'emoji': emoji,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
      'source': source,
      'servingSize': servingSize,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      emoji: json['emoji'],
      calories: json['calories'],
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      fat: json['fat']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['mealType'],
      source: json['source'],
      servingSize: json['servingSize'],
    );
  }

  /// Calculate total macros
  Map<String, double> get totalMacros {
    return {
      'calories': calories.toDouble(),
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
