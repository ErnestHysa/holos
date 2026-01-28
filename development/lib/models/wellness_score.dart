/// Wellness score model for dashboard
class WellnessScore {
  final String userId;
  final DateTime date;
  final int totalScore; // 0 to 100
  final int sleepScore; // Sub-score 0-100
  final int nutritionScore; // Sub-score 0-100
  final int activityScore; // Sub-score 0-100
  final int stressScore; // Sub-score 0-100
  final String? trend; // "↑ 5 points", "↓ 2 points", etc.

  WellnessScore({
    required this.userId,
    required this.date,
    required this.totalScore,
    required this.sleepScore,
    required this.nutritionScore,
    required this.activityScore,
    required this.stressScore,
    this.trend,
  });

  /// Calculate total score with dynamic weighting
  /// Weighted based on user goals (can be adjusted later)
  static int calculateTotal({
    required int sleepScore,
    required int nutritionScore,
    required int activityScore,
    required int stressScore,
    int sleepWeight = 35, // Default weights
    int nutritionWeight = 30,
    int activityWeight = 20,
    int stressWeight = 15,
  }) {
    final total = (sleepScore * sleepWeight +
                  nutritionScore * nutritionWeight +
                  activityScore * activityWeight +
                  stressScore * stressWeight) /
                 100;

    return total.round();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'totalScore': totalScore,
      'sleepScore': sleepScore,
      'nutritionScore': nutritionScore,
      'activityScore': activityScore,
      'stressScore': stressScore,
      'trend': trend,
    };
  }

  factory WellnessScore.fromJson(Map<String, dynamic> json) {
    return WellnessScore(
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      totalScore: json['totalScore'],
      sleepScore: json['sleepScore'],
      nutritionScore: json['nutritionScore'],
      activityScore: json['activityScore'],
      stressScore: json['stressScore'],
      trend: json['trend'],
    );
  }

  /// Get color based on score value
  static String getScoreColor(int score) {
    if (score >= 80) return 'success';
    if (score >= 60) return 'warning';
    return 'error';
  }
}
