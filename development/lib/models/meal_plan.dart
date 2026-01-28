/// Meal plan model for adaptive meal planning
class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final List<PlannedMeal> meals;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  MealPlan copyWith({
    List<PlannedMeal>? meals,
  }) {
    return MealPlan(
      id: id,
      userId: userId,
      date: date,
      meals: meals ?? this.meals,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      meals: (json['meals'] as List)
          .map((m) => PlannedMeal.fromJson(m))
          .toList(),
      totalCalories: json['totalCalories'],
      totalProtein: json['totalProtein']?.toDouble(),
      totalCarbs: json['totalCarbs']?.toDouble(),
      totalFat: json['totalFat']?.toDouble(),
    );
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (meals.isEmpty) return 0.0;
    final completedMeals = meals.where((m) => m.name.isNotEmpty).length;
    return completedMeals / meals.length;
  }
}

/// Planned meal data model
class PlannedMeal {
  final String id;
  final String mealType; // breakfast, lunch, dinner, snack
  final String name;
  final String? emoji;
  final Map<String, int> macros;
  final String? time;
  final bool isAIgenerated;

  PlannedMeal({
    required this.id,
    required this.mealType,
    this.name = '',
    this.emoji,
    required this.macros,
    this.time,
    this.isAIgenerated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'name': name,
      'emoji': emoji,
      'macros': macros,
      'time': time,
      'isAIgenerated': isAIgenerated,
    };
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id'],
      mealType: json['mealType'],
      name: json['name'] ?? '',
      emoji: json['emoji'],
      macros: Map<String, int>.from(json['macros']),
      time: json['time'],
      isAIgenerated: json['isAIgenerated'] ?? false,
    );
  }

  PlannedMeal copyWith({
    String? name,
    String? emoji,
    Map<String, int>? macros,
    String? time,
    bool? isAIgenerated,
  }) {
    return PlannedMeal(
      id: id,
      mealType: mealType,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      macros: macros ?? this.macros,
      time: time ?? this.time,
      isAIgenerated: isAIgenerated ?? this.isAIgenerated,
    );
  }

  /// Get formatted macros string
  String get formattedMacros {
    return '${macros['calories']} kcal | P:${macros['protein']}g C:${macros['carbs']}g F:${macros['fat']}g';
  }

  /// Check if meal is planned (has a name)
  bool get isPlanned => name.isNotEmpty;
}
