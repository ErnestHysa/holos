import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../models/health_data.dart';

/// Apple Health Service - iOS HealthKit integration
/// Uses the health package to fetch data from Apple Health
class AppleHealthService {
  // Health instance from the health package
  Health? _health;

  // List of health data types to request
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
  ];

  // List of permissions to request
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  // Stream subscription for health updates
  StreamSubscription<List<HealthDataPoint>>? _healthUpdateSubscription;

  // Callback for health data updates
  Function(HealthData)? _onHealthDataUpdate;

  /// Initialize the health service
  Future<void> initialize() async {
    if (!Platform.isIOS) {
      debugPrint('Apple Health is only available on iOS');
      return;
    }

    _health = Health();

    // Check if health data is available on this device
    final bool isAvailable =
        await _health!.hasPermissions(_dataTypes, permissions: _permissions) ??
            false;

    if (!isAvailable) {
      debugPrint('HealthKit not available on this device');
    }
  }

  /// Check if we have permission to access health data
  Future<bool> hasPermission() async {
    if (_health == null) {
      await initialize();
    }

    if (_health == null) return false;

    try {
      // Try to get permissions status
      final permissions =
          await _health!.hasPermissions(_dataTypes, permissions: _permissions);
      return permissions ?? false;
    } catch (e) {
      debugPrint('Error checking Apple Health permissions: $e');
      return false;
    }
  }

  /// Request permission to access health data
  /// Returns: true if granted, false if denied
  Future<bool> requestPermission() async {
    if (_health == null) {
      await initialize();
    }

    if (_health == null) return false;

    try {
      // Request permissions for all data types
      final bool wasGranted = await _health!
              .requestAuthorization(_dataTypes, permissions: _permissions) ??
          false;

      if (wasGranted) {
        debugPrint('Apple Health permissions granted');
        // Set up background observer
        _setUpObserver();
      } else {
        debugPrint('Apple Health permissions denied');
      }

      return wasGranted;
    } catch (e) {
      debugPrint('Error requesting Apple Health permissions: $e');
      return false;
    }
  }

  /// Set up HealthKit observer for background updates
  void _setUpObserver() {
    // HealthKit observer is not directly supported in health 10.x Stream API
    debugPrint(
        'Background observer not supported in this version of the health package');
  }

  /// Fetch latest data and notify callback
  Future<void> _fetchAndNotifyLatest() async {
    if (_onHealthDataUpdate == null) return;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final data = await getTodayData(userId: 'current_user', date: startOfDay);

    if (data != null) {
      _onHealthDataUpdate!(data);
    }
  }

  /// Get today's health data
  Future<HealthData?> getTodayData({
    required String userId,
    DateTime? date,
  }) async {
    if (_health == null) {
      await initialize();
    }

    if (_health == null) return null;

    try {
      final now = date ?? DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime.now().isAfter(now.add(const Duration(days: 1)))
          ? now.add(const Duration(days: 1))
          : DateTime.now();

      // Fetch all data types in parallel
      final results = await Future.wait([
        _getSteps(startDate, endDate),
        _getActiveCalories(startDate, endDate),
        _getHeartRate(startDate, endDate),
        _getSleepData(startDate, endDate),
        _getWorkouts(startDate, endDate),
        _getHeartRateVariability(startDate, endDate),
      ]);

      final steps = results[0] as int?;
      final activeCalories = results[1] as int?;
      final heartRate = results[2] as int?;
      final sleepData = results[3] as Map<String, dynamic>?;
      final workouts = results[4] as List<Workout>?;
      final hrv = results[5] as int?;

      // Calculate sleep duration in hours
      double? sleepDuration = sleepData?['duration'] as double?;
      double? sleepQuality = sleepData?['quality'] as double?;
      double? deepSleepPercent = sleepData?['deepSleepPercent'] as double?;

      // Estimate total calories (active + resting metabolic rate ~1500)
      final totalCalories =
          activeCalories != null ? activeCalories + 1500 : null;

      return HealthData(
        userId: userId,
        date: startDate,
        sleepDuration: sleepDuration,
        sleepQuality: sleepQuality,
        deepSleepPercent: deepSleepPercent,
        steps: steps,
        activeCalories: activeCalories,
        totalCaloriesBurned: totalCalories,
        workouts: workouts?.isNotEmpty == true ? workouts : null,
        avgHeartRate: heartRate,
        heartRateVariability: hrv,
        stressLevel: null, // Apple Health doesn't directly provide stress
      );
    } catch (e) {
      debugPrint('Error fetching today\'s health data from Apple Health: $e');
      return null;
    }
  }

  /// Get health data for a date range
  Future<List<HealthData>?> getDataForRange(
    DateTime startDate,
    DateTime endDate, {
    required String userId,
  }) async {
    if (_health == null) {
      await initialize();
    }

    if (_health == null) return null;

    try {
      List<HealthData> dataList = [];

      // Iterate through each day in the range
      DateTime currentDay =
          DateTime(startDate.year, startDate.month, startDate.day);
      final endDay =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      while (
          currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
        final nextDay = currentDay.add(const Duration(days: 1));

        final data = await getTodayData(
          userId: userId,
          date: currentDay,
        );

        if (data != null) {
          dataList.add(data);
        }

        currentDay = nextDay;
      }

      return dataList;
    } catch (e) {
      debugPrint('Error fetching health data range from Apple Health: $e');
      return null;
    }
  }

  /// Get step count for a date range
  Future<int?> _getSteps(DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) return 0;

      // Sum all step data points
      int totalSteps = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalSteps += value.toInt();
      }

      return totalSteps;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      return null;
    }
  }

  /// Get active calories burned for a date range
  Future<int?> _getActiveCalories(DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) return 0;

      // Sum all active calorie data points
      int totalCalories = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalCalories += value.toInt();
      }

      return totalCalories;
    } catch (e) {
      debugPrint('Error getting active calories: $e');
      return null;
    }
  }

  /// Get average heart rate for a date range
  Future<int?> _getHeartRate(DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) return null;

      // Calculate average heart rate
      int totalHeartRate = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalHeartRate += value.toInt();
      }

      return totalHeartRate ~/ healthData.length;
    } catch (e) {
      debugPrint('Error getting heart rate: $e');
      return null;
    }
  }

  /// Get sleep data for a date range
  Future<Map<String, dynamic>?> _getSleepData(
      DateTime startDate, DateTime endDate) async {
    try {
      // Get sleep analysis data
      List<HealthDataPoint> inBedData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_IN_BED],
        startTime: startDate,
        endTime: endDate,
      );

      List<HealthDataPoint> asleepData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: startDate,
        endTime: endDate,
      );

      List<HealthDataPoint> deepSleepData =
          await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_DEEP],
        startTime: startDate,
        endTime: endDate,
      );

      if (asleepData.isEmpty && inBedData.isEmpty) {
        return null;
      }

      // Calculate sleep duration in hours
      double totalSleepMinutes = 0;
      double totalDeepSleepMinutes = 0;

      for (var dataPoint in asleepData) {
        final duration =
            dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes;
        totalSleepMinutes += duration;
      }

      for (var dataPoint in deepSleepData) {
        final duration =
            dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes;
        totalDeepSleepMinutes += duration;
      }

      final sleepDurationHours = totalSleepMinutes / 60;
      final deepSleepPercent = totalSleepMinutes > 0
          ? (totalDeepSleepMinutes / totalSleepMinutes) * 100
          : 0.0;

      // Calculate sleep quality (0.0 to 1.0) based on duration and deep sleep
      // Ideal: 7-9 hours with 15-25% deep sleep
      double sleepQuality = 0.5; // Default

      if (sleepDurationHours >= 7 && sleepDurationHours <= 9) {
        sleepQuality = 0.8; // Good duration
      } else if (sleepDurationHours >= 6 && sleepDurationHours < 7) {
        sleepQuality = 0.6; // Fair duration
      } else if (sleepDurationHours > 9) {
        sleepQuality = 0.7; // Too much sleep can indicate poor quality
      }

      // Adjust for deep sleep percentage
      if (deepSleepPercent >= 15 && deepSleepPercent <= 25) {
        sleepQuality += 0.1; // Good deep sleep
      } else if (deepSleepPercent < 10) {
        sleepQuality -= 0.1; // Poor deep sleep
      }

      // Clamp to 0.0-1.0 range
      sleepQuality = sleepQuality.clamp(0.0, 1.0);

      return {
        'duration': sleepDurationHours,
        'quality': sleepQuality,
        'deepSleepPercent': deepSleepPercent,
      };
    } catch (e) {
      debugPrint('Error getting sleep data: $e');
      return null;
    }
  }

  /// Get workouts for a date range
  Future<List<Workout>> _getWorkouts(
      DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> workoutData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: startDate,
        endTime: endDate,
      );

      if (workoutData.isEmpty) return [];

      List<Workout> workouts = [];

      for (var dataPoint in workoutData) {
        final workoutType = dataPoint.unit?.name ?? 'UNKNOWN';
        final duration =
            dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes;

        // Get workout type string
        String workoutTypeStr = _getWorkoutTypeString(workoutType);

        workouts.add(Workout(
          id: dataPoint.sourceId,
          type: workoutTypeStr,
          startTime: dataPoint.dateFrom,
          endTime: dataPoint.dateTo,
          duration: duration,
          caloriesBurned: 0, // Will need to fetch separately
        ));
      }

      return workouts;
    } catch (e) {
      debugPrint('Error getting workouts: $e');
      return [];
    }
  }

  /// Get heart rate variability for a date range
  Future<int?> _getHeartRateVariability(
      DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE_VARIABILITY_SDNN],
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) return null;

      // Calculate average HRV
      int totalHrv = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalHrv += value.toInt();
      }

      return totalHrv ~/ healthData.length;
    } catch (e) {
      debugPrint('Error getting HRV: $e');
      return null;
    }
  }

  /// Convert workout type from HealthKit to readable string
  String _getWorkoutTypeString(String healthKitType) {
    switch (healthKitType.toUpperCase()) {
      case 'RUNNING':
      case 'OUTDOOR_RUN':
        return 'Running';
      case 'WALKING':
      case 'OUTDOOR_WALK':
        return 'Walking';
      case 'CYCLING':
      case 'OUTDOOR_CYCLE':
        return 'Cycling';
      case 'SWIMMING':
        return 'Swimming';
      case 'HIKING':
        return 'Hiking';
      case 'YOGA':
        return 'Yoga';
      case 'STRENGTH_TRAINING':
        return 'Strength Training';
      case 'ELLIPTICAL':
        return 'Elliptical';
      case 'ROWING':
        return 'Rowing';
      case 'BOXING':
        return 'Boxing';
      default:
        return 'Workout';
    }
  }

  /// Subscribe to health data updates
  void subscribeToUpdates(Function(HealthData) onUpdate) {
    _onHealthDataUpdate = onUpdate;
    _setUpObserver();
  }

  /// Disconnect from Apple Health
  Future<void> disconnect() async {
    await _healthUpdateSubscription?.cancel();
    _healthUpdateSubscription = null;
    _onHealthDataUpdate = null;
  }

  /// Dispose resources
  void dispose() {
    _healthUpdateSubscription?.cancel();
  }
}
