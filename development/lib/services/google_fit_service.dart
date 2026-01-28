import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../models/health_data.dart';

/// Google Fit Service - Android Google Fit integration
/// Uses the health package to fetch data from Google Fit on Android
class GoogleFitService {
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
  ];

  // Stream subscription for health updates
  StreamSubscription<List<HealthDataPoint>>? _healthUpdateSubscription;

  // Callback for health data updates
  Function(HealthData)? _onHealthDataUpdate;

  /// Initialize the health service
  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      debugPrint('Google Fit is only available on Android');
      return;
    }

    _health = Health();

    // Check if Google Fit is available on this device
    try {
      final bool isAvailable = await _health!.hasPermissions(
            _dataTypes,
            permissions: _permissions,
          ) ??
          false;

      if (!isAvailable) {
        debugPrint('Google Fit not available on this device');
      }
    } catch (e) {
      debugPrint('Error checking Google Fit availability: $e');
    }
  }

  /// Check if we have permission to access health data
  Future<bool> hasPermission() async {
    if (_health == null) {
      await initialize();
    }

    if (_health == null) return false;

    try {
      final permissions = await _health!.hasPermissions(
        _dataTypes,
        permissions: _permissions,
      );
      return permissions ?? false;
    } catch (e) {
      debugPrint('Error checking Google Fit permissions: $e');
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
      final bool wasGranted = await _health!.requestAuthorization(
            _dataTypes,
            permissions: _permissions,
          ) ??
          false;

      if (wasGranted) {
        debugPrint('Google Fit permissions granted');
        // Set up background observer
        _setUpObserver();
      } else {
        debugPrint('Google Fit permissions denied');
      }

      return wasGranted;
    } catch (e) {
      debugPrint('Error requesting Google Fit permissions: $e');
      return false;
    }
  }

  /// Set up observer for background updates
  void _setUpObserver() {
    // HealthKit/Google Fit observer is not directly supported in health 10.x Stream API
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

      // Parse sleep data
      double? sleepDuration = sleepData?['duration'] as double?;
      double? sleepQuality = sleepData?['quality'] as double?;
      double? deepSleepPercent = sleepData?['deepSleepPercent'] as double?;

      // Calculate total calories
      final totalCalories = activeCalories != null
          ? activeCalories + 1500 // Add resting metabolic rate
          : null;

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
        stressLevel: null,
      );
    } catch (e) {
      debugPrint('Error fetching today\'s health data from Google Fit: $e');
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
      debugPrint('Error fetching health data range from Google Fit: $e');
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

      int totalSteps = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalSteps += value.toInt();
      }

      return totalSteps;
    } catch (e) {
      debugPrint('Error getting steps from Google Fit: $e');
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

      int totalCalories = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalCalories += value.toInt();
      }

      return totalCalories;
    } catch (e) {
      debugPrint('Error getting active calories from Google Fit: $e');
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

      // Calculate average heart rate using double division for accuracy
      int totalHeartRate = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalHeartRate += value.toInt();
      }

      return (totalHeartRate / healthData.length).round();
    } catch (e) {
      debugPrint('Error getting heart rate from Google Fit: $e');
      return null;
    }
  }

  /// Get sleep data for a date range
  Future<Map<String, dynamic>?> _getSleepData(
      DateTime startDate, DateTime endDate) async {
    try {
      List<HealthDataPoint> asleepData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: startDate,
        endTime: endDate,
      );

      if (asleepData.isEmpty) {
        return null;
      }

      double totalSleepMinutes = 0;

      for (var dataPoint in asleepData) {
        final duration =
            dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes;
        totalSleepMinutes += duration;
      }

      final sleepDurationHours = totalSleepMinutes / 60;

      // Calculate sleep quality (simplified for Google Fit)
      double sleepQuality = 0.5;

      if (sleepDurationHours >= 7 && sleepDurationHours <= 9) {
        sleepQuality = 0.8;
      } else if (sleepDurationHours >= 6 && sleepDurationHours < 7) {
        sleepQuality = 0.6;
      } else if (sleepDurationHours > 9) {
        sleepQuality = 0.7;
      }

      sleepQuality = sleepQuality.clamp(0.0, 1.0);

      return {
        'duration': sleepDurationHours,
        'quality': sleepQuality,
        'deepSleepPercent':
            20.0, // Default value since Google Fit doesn't always provide this
      };
    } catch (e) {
      debugPrint('Error getting sleep data from Google Fit: $e');
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

        String workoutTypeStr = _getWorkoutTypeString(workoutType);

        workouts.add(Workout(
          id: dataPoint.sourceId,
          type: workoutTypeStr,
          startTime: dataPoint.dateFrom,
          endTime: dataPoint.dateTo,
          duration: duration,
          caloriesBurned: 0,
        ));
      }

      return workouts;
    } catch (e) {
      debugPrint('Error getting workouts from Google Fit: $e');
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

      // Calculate average HRV using double division for accuracy
      int totalHrv = 0;
      for (var dataPoint in healthData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalHrv += value.toInt();
      }

      return (totalHrv / healthData.length).round();
    } catch (e) {
      debugPrint('Error getting HRV from Google Fit: $e');
      return null;
    }
  }

  /// Convert workout type to readable string
  String _getWorkoutTypeString(String fitType) {
    switch (fitType.toUpperCase()) {
      case 'RUNNING':
      case 'OUTDOOR_RUN':
        return 'Running';
      case 'WALKING':
        return 'Walking';
      case 'CYCLING':
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
      default:
        return 'Workout';
    }
  }

  /// Subscribe to health data updates
  void subscribeToUpdates(Function(HealthData) onUpdate) {
    _onHealthDataUpdate = onUpdate;
    _setUpObserver();
  }

  /// Disconnect from Google Fit
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
