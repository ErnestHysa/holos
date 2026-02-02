/// Notification preference model for user notification settings
class NotificationPreference {
  final String userId;
  final bool wakeUpEnabled;
  final String wakeUpTime; // Format: "07:00"
  final bool lunchEnabled;
  final String lunchTime; // Format: "12:00"
  final bool dinnerEnabled;
  final String dinnerTime; // Format: "19:00"
  final bool quietHoursEnabled;
  final String quietStart; // Format: "22:00"
  final String quietEnd; // Format: "07:00"
  final int dailyLimit; // 1-3 notifications per day

  NotificationPreference({
    required this.userId,
    this.wakeUpEnabled = true,
    this.wakeUpTime = '07:00',
    this.lunchEnabled = true,
    this.lunchTime = '12:00',
    this.dinnerEnabled = true,
    this.dinnerTime = '19:00',
    this.quietHoursEnabled = false,
    this.quietStart = '22:00',
    this.quietEnd = '07:00',
    this.dailyLimit = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'wakeUpEnabled': wakeUpEnabled,
      'wakeUpTime': wakeUpTime,
      'lunchEnabled': lunchEnabled,
      'lunchTime': lunchTime,
      'dinnerEnabled': dinnerEnabled,
      'dinnerTime': dinnerTime,
      'quietHoursEnabled': quietHoursEnabled,
      'quietStart': quietStart,
      'quietEnd': quietEnd,
      'dailyLimit': dailyLimit,
    };
  }

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    // Validate time string format (HH:MM)
    String _validateTime(String? time, String defaultValue) {
      if (time == null) return defaultValue;

      final parts = time!.split(':');
      if (parts.length != 2) return defaultValue;

      try {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // Validate range: 00-23 hours, 00-59 minutes
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
          return defaultValue;
        }

        // Format back to HH:MM with leading zeros
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return defaultValue;
      }
    }

    return NotificationPreference(
      userId: json['userId'] ?? 'unknown',
      wakeUpEnabled: json['wakeUpEnabled'] ?? true,
      wakeUpTime: _validateTime(json['wakeUpTime'] as String?, '07:00'),
      lunchEnabled: json['lunchEnabled'] ?? true,
      lunchTime: _validateTime(json['lunchTime'] as String?, '12:00'),
      dinnerEnabled: json['dinnerEnabled'] ?? true,
      dinnerTime: _validateTime(json['dinnerTime'] as String?, '19:00'),
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      quietStart: _validateTime(json['quietStart'] as String?, '22:00'),
      quietEnd: _validateTime(json['quietEnd'] as String?, '07:00'),
      dailyLimit: json['dailyLimit'] ?? 3,
    );
  }

  /// Copy with modified fields
  NotificationPreference copyWith({
    bool? wakeUpEnabled,
    String? wakeUpTime,
    bool? lunchEnabled,
    String? lunchTime,
    bool? dinnerEnabled,
    String? dinnerTime,
    bool? quietHoursEnabled,
    String? quietStart,
    String? quietEnd,
    int? dailyLimit,
  }) {
    return NotificationPreference(
      userId: userId,
      wakeUpEnabled: wakeUpEnabled ?? this.wakeUpEnabled,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      dailyLimit: dailyLimit ?? this.dailyLimit,
    );
  }
}

/// Meal notification data model
class MealNotification {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String title;
  final String body;
  final String mealType; // breakfast, lunch, dinner, snack
  final String mealName;
  final MealSuggestion suggestion;
  final bool isRead;

  MealNotification({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.title,
    required this.body,
    required this.mealType,
    required this.mealName,
    required this.suggestion,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'body': body,
      'mealType': mealType,
      'mealName': mealName,
      'suggestion': suggestion.toJson(),
      'isRead': isRead,
    };
  }

  factory MealNotification.fromJson(Map<String, dynamic> json) {
    return MealNotification(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      body: json['body'],
      mealType: json['mealType'],
      mealName: json['mealName'],
      suggestion: MealSuggestion.fromJson(json['suggestion']),
      isRead: json['isRead'] ?? false,
    );
  }

  MealNotification copyWith({bool? isRead}) {
    return MealNotification(
      id: id,
      userId: userId,
      timestamp: timestamp,
      title: title,
      body: body,
      mealType: mealType,
      mealName: mealName,
      suggestion: suggestion,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Meal suggestion data model for notifications
class MealSuggestion {
  final String mealName;
  final String? emoji;
  final String description;
  final MealMacros macros;

  MealSuggestion({
    required this.mealName,
    this.emoji,
    required this.description,
    required this.macros,
  });

  Map<String, dynamic> toJson() {
    return {
      'mealName': mealName,
      'emoji': emoji,
      'description': description,
      'macros': macros.toJson(),
    };
  }

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      mealName: json['mealName'],
      emoji: json['emoji'],
      description: json['description'],
      macros: MealMacros.fromJson(json['macros']),
    );
  }
}

/// Meal macros data model (shared with FoodEntry)
class MealMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MealMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory MealMacros.fromJson(Map<String, dynamic> json) {
    return MealMacros(
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
    );
  }

  String get formatted {
    return '$calories kcal | P:${protein}g C:${carbs}g F:${fat}g';
  }
}
