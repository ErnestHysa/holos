import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../models/health_data.dart';

/// Samsung Health Service - Uses health package for Samsung Health integration
/// On Android, the health package integrates with Samsung Health
class SamsungHealthService {
  static final Health _health = Health();

  // Health data types to request
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
  ];

  // Permissions (all read for now)
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  // Connection state
  bool _isAvailable = false;
  bool _isConnected = false;

  // Event controller for connection status updates
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  SamsungHealthService();

  /// Check if Samsung Health is available on this device
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      debugPrint('Samsung Health is only available on Android');
      return false;
    }

    try {
      // Check if we can request permissions (Samsung Health installed)
      _isAvailable = await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
      return _isAvailable;
    } catch (e) {
      debugPrint('Samsung Health not available: $e');
      return false;
    }
  }

  /// Check if we have permission to access health data
  Future<bool> hasPermission() async {
    if (!_isAvailable) return false;

    try {
      final bool hasPermissions = await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
      _isConnected = hasPermissions;
      return _isConnected;
    } catch (e) {
      debugPrint('Error checking Samsung Health permissions: $e');
      return false;
    }
  }

  /// Request permission to access health data
  /// Returns: true if granted, false if denied
  Future<bool> requestPermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      _showError(context, 'Samsung Health is only available on Android');
      return false;
    }

    try {
      // Request permissions from Samsung Health
      final bool granted = await _health.requestAuthorization(_dataTypes, permissions: _permissions);

      if (granted == true) {
        _isConnected = true;
        _connectionStatusController.add(true);
        debugPrint('Samsung Health connected successfully!');
      } else {
        _isConnected = false;
        _connectionStatusController.add(false);
        debugPrint('Samsung Health permission denied');
        if (context.mounted) {
          _showConnectionHelp(context);
        }
      }

      return _isConnected;
    } catch (e) {
      debugPrint('Error requesting Samsung Health permissions: $e');
      if (context.mounted) {
        _showConnectionHelp(context);
      }
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showConnectionHelp(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Make sure Samsung Health is installed and you grant permissions when prompted.'),
          backgroundColor: Color(0xFFFF6B6B),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// Get today's health data
  Future<HealthData?> getTodayData({
    required String userId,
    DateTime? date,
  }) async {
    if (!_isConnected) {
      debugPrint('Samsung Health is not connected');
      return null;
    }

    try {
      final now = date ?? DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endTime = now;

      // Fetch steps
      int? steps = await _getSteps(startOfDay, endTime);

      // Fetch sleep data
      final sleepData = await _getSleepData(now);
      double? sleepDuration = sleepData['duration'];
      double? sleepQuality = sleepData['quality'];
      double? deepSleepPercent = sleepData['deepSleepPercent'];

      // Fetch heart rate
      int? avgHeartRate = await _getHeartRate(startOfDay, endTime);

      // Fetch calories
      final caloriesData = await _getCalories(startOfDay, endTime);
      int? activeCalories = caloriesData['active'];
      int? totalCalories = caloriesData['total'];

      return HealthData(
        userId: userId,
        date: now,
        steps: steps,
        sleepDuration: sleepDuration,
        sleepQuality: sleepQuality,
        deepSleepPercent: deepSleepPercent,
        avgHeartRate: avgHeartRate,
        heartRateVariability: null, // Not available
        activeCalories: activeCalories,
        totalCaloriesBurned: totalCalories,
        stressLevel: null, // Would need additional calculation
        workouts: null,
      );
    } catch (e) {
      debugPrint('Error fetching today\'s health data from Samsung Health: $e');
      return null;
    }
  }

  /// Get health data for a date range
  Future<List<HealthData>?> getDataForRange(
    DateTime startDate,
    DateTime endDate, {
    required String userId,
  }) async {
    if (!_isConnected) {
      return null;
    }

    try {
      List<HealthData> healthDataList = [];

      // Get data for each day in the range
      DateTime currentDay = DateTime(startDate.year, startDate.month, startDate.day);
      final endDay = DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
        final nextDay = currentDay.add(const Duration(days: 1));
        final data = await getTodayData(
          userId: userId,
          date: nextDay.isAfter(endDate) ? endDate : nextDay,
        );

        if (data != null) {
          healthDataList.add(data);
        }

        currentDay = nextDay;
      }

      return healthDataList;
    } catch (e) {
      debugPrint('Error fetching health data range from Samsung Health: $e');
      return null;
    }
  }

  Future<int?> _getSteps(DateTime startTime, DateTime endTime) async {
    try {
      final List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startTime,
        endTime: endTime,
      );

      if (healthData.isEmpty) return null;

      // Sum up all steps
      int totalSteps = 0;
      for (var data in healthData) {
        final steps = (data.value as num?)?.toInt() ?? 0;
        totalSteps += steps;
      }

      return totalSteps > 0 ? totalSteps : null;
    } catch (e) {
      debugPrint('Error getting steps: $e');
      return null;
    }
  }

  Future<Map<String, double?>> _getSleepData(DateTime date) async {
    final startTime = DateTime(date.year, date.month, date.day);
    final endTime = startTime.add(const Duration(days: 1));

    double? duration;
    double? quality;
    double? deepSleepPercent;

    try {
      // Get sleep data
      final List<HealthDataPoint> sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_DEEP],
        startTime: startTime,
        endTime: endTime,
      );

      if (sleepData.isNotEmpty) {
        // Calculate total sleep duration in hours
        int totalSleepMinutes = 0;
        int deepSleepMinutes = 0;

        for (var data in sleepData) {
          if (data.type == HealthDataType.SLEEP_ASLEEP) {
            final sleepEnd = data.dateTo;
            final sleepStart = data.dateFrom;
            totalSleepMinutes += sleepEnd.difference(sleepStart).inMinutes;
          } else if (data.type == HealthDataType.SLEEP_DEEP) {
            final sleepEnd = data.dateTo;
            final sleepStart = data.dateFrom;
            deepSleepMinutes += sleepEnd.difference(sleepStart).inMinutes;
          }
        }

        if (totalSleepMinutes > 0) {
          duration = totalSleepMinutes / 60.0; // Convert to hours
          deepSleepPercent = totalSleepMinutes > 0 ? (deepSleepMinutes / totalSleepMinutes) : 0.0;

          // Calculate sleep quality based on duration
          final hours = duration;
          quality = switch (hours) {
            >= 7.0 && <= 9.0 => 0.9,
            >= 6.0 && < 7.0 => 0.75,
            > 9.0 && <= 10.0 => 0.7,
            >= 5.0 && < 6.0 => 0.5,
            _ => 0.3,
          };
        }
      }
    } catch (e) {
      debugPrint('Error getting sleep data: $e');
    }

    return {'duration': duration, 'quality': quality, 'deepSleepPercent': deepSleepPercent};
  }

  Future<int?> _getHeartRate(DateTime startTime, DateTime endTime) async {
    try {
      final List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startTime,
        endTime: endTime,
      );

      if (healthData.isEmpty) return null;

      // Calculate average heart rate
      int totalHeartRate = 0;
      int count = 0;

      for (var data in healthData) {
        final hr = (data.value as num?)?.toInt() ?? 0;
        if (hr > 0) {
          totalHeartRate += hr;
          count++;
        }
      }

      return count > 0 ? (totalHeartRate / count).round() : null;
    } catch (e) {
      debugPrint('Error getting heart rate: $e');
      return null;
    }
  }

  Future<Map<String, int?>> _getCalories(DateTime startTime, DateTime endTime) async {
    int? activeCalories;
    int? totalCalories;

    try {
      // Get active calories burned
      final List<HealthDataPoint> activeData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startTime,
        endTime: endTime,
      );

      int totalActive = 0;
      for (var data in activeData) {
        final cal = (data.value as num?)?.toInt() ?? 0;
        totalActive += cal;
      }
      activeCalories = totalActive > 0 ? totalActive : null;

      // Get basal calories burned
      final List<HealthDataPoint> basalData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BASAL_ENERGY_BURNED],
        startTime: startTime,
        endTime: endTime,
      );

      int totalBasal = 0;
      for (var data in basalData) {
        final cal = (data.value as num?)?.toInt() ?? 0;
        totalBasal += cal;
      }

      // Total = active + basal
      if (totalActive > 0 || totalBasal > 0) {
        totalCalories = totalActive + totalBasal;
      }
    } catch (e) {
      debugPrint('Error getting calories: $e');
    }

    return {'active': activeCalories, 'total': totalCalories};
  }

  /// Subscribe to health data updates
  void subscribeToUpdates(Function(HealthData) onUpdate) {
    // The health package doesn't support real-time updates
    // You would need to poll for updates
    debugPrint('Samsung Health subscribeToUpdates: polling for updates');
  }

  /// Disconnect from Samsung Health
  Future<void> disconnect() async {
    _isConnected = false;
    _connectionStatusController.add(false);
    debugPrint('Samsung Health disconnected');
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}
