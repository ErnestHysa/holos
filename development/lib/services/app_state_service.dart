import 'package:shared_preferences/shared_preferences.dart';

/// Simple persisted app state for onboarding and profile bootstrap.
class AppStateService {
  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kSelectedGoal = 'selected_goal';
  static const _kDietaryRestrictions = 'dietary_restrictions';
  static const _kAllergens = 'allergens';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingComplete, value);
  }

  Future<String?> getSelectedGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSelectedGoal);
  }

  Future<void> setSelectedGoal(String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedGoal, goalId);
  }

  Future<List<String>> getDietaryRestrictions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kDietaryRestrictions) ?? <String>[];
  }

  Future<void> setDietaryRestrictions(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kDietaryRestrictions, values);
  }

  Future<List<String>> getAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kAllergens) ?? <String>[];
  }

  Future<void> setAllergens(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAllergens, values);
  }
}
