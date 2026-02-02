/// Health data model from health platforms
class HealthData {
  final String userId;
  final DateTime date;

  // Sleep Data
  final double? sleepDuration; // in hours
  final double? sleepQuality; // 0.0 to 1.0
  final double? deepSleepPercent;

  // Activity Data
  final int? steps;
  final int? activeCalories;
  final int? totalCaloriesBurned;
  final List<Workout>? workouts;

  // Stress/Heart Data
  final int? avgHeartRate;
  final int? heartRateVariability;
  final double? stressLevel; // 0.0 to 1.0

  HealthData({
    required this.userId,
    required this.date,
    this.sleepDuration,
    this.sleepQuality,
    this.deepSleepPercent,
    this.steps,
    this.activeCalories,
    this.totalCaloriesBurned,
    this.workouts,
    this.avgHeartRate,
    this.heartRateVariability,
    this.stressLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'deepSleepPercent': deepSleepPercent,
      'steps': steps,
      'activeCalories': activeCalories,
      'totalCaloriesBurned': totalCaloriesBurned,
      'workouts': workouts?.map((w) => w.toJson()).toList(),
      'avgHeartRate': avgHeartRate,
      'heartRateVariability': heartRateVariability,
      'stressLevel': stressLevel,
    };
  }
}

/// Workout data model
class Workout {
  final String id;
  final String type; // running, cycling, swimming, etc.
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final int caloriesBurned;

  Workout({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.caloriesBurned,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      duration: json['duration'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'caloriesBurned': caloriesBurned,
    };
  }
}
