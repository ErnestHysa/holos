/// User model for authentication and profile data
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? primaryGoal;
  final List<String>? dietaryPreferences;
  final List<String>? allergens;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.primaryGoal,
    this.dietaryPreferences,
    this.allergens,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'primaryGoal': primaryGoal,
      'dietaryPreferences': dietaryPreferences,
      'allergens': allergens,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      primaryGoal: json['primaryGoal'],
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : null,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
