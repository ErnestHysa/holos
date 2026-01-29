import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/health_data.dart';
import 'apple_health_service.dart';
import 'google_fit_service.dart';
import 'samsung_health_service.dart';

/// Health Service - Unified interface for all health platforms
/// Supports: Apple Health (iOS), Google Fit (Android), Samsung Health (Android)
class HealthService {
  // Singleton pattern
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // Platform-specific services
  AppleHealthService? _appleHealthService;
  GoogleFitService? _googleFitService;
  SamsungHealthService? _samsungHealthService;

  // Health data change stream controller
  final StreamController<HealthData> _healthDataController =
      StreamController<HealthData>.broadcast();

  Stream<HealthData> get healthDataStream => _healthDataController.stream;

  // Track stream controller state to prevent double-close
  bool _controllerClosed = false;

  // Supported platforms on this device
  Set<HealthPlatform> _supportedPlatforms = {};
  Set<HealthPlatform> _connectedPlatforms = {};

  Set<HealthPlatform> get supportedPlatforms => _supportedPlatforms;
  Set<HealthPlatform> get connectedPlatforms => _connectedPlatforms;

  /// Initialize health service - detect available platforms
  Future<void> initialize() async {
    if (Platform.isIOS) {
      _appleHealthService = AppleHealthService();
      _supportedPlatforms.add(HealthPlatform.appleHealth);
    } else if (Platform.isAndroid) {
      _googleFitService = GoogleFitService();
      _supportedPlatforms.add(HealthPlatform.googleFit);

      // Samsung Health is optional on Android
      try {
        _samsungHealthService = SamsungHealthService();
        final samsungAvailable = await _samsungHealthService!.isAvailable();
        if (samsungAvailable) {
          _supportedPlatforms.add(HealthPlatform.samsungHealth);
        }
      } catch (e) {
        // Samsung Health not available
        debugPrint('Samsung Health not available: $e');
      }
    }
  }

  /// Check if permissions are granted for a platform
  Future<bool> hasPermission(HealthPlatform platform) async {
    switch (platform) {
      case HealthPlatform.appleHealth:
        return await _appleHealthService?.hasPermission() ?? false;
      case HealthPlatform.googleFit:
        return await _googleFitService?.hasPermission() ?? false;
      case HealthPlatform.samsungHealth:
        return await _samsungHealthService?.hasPermission() ?? false;
    }
  }

  /// Request permissions for a specific platform
  /// Returns: true if granted, false if denied
  Future<bool> requestPermission(
    BuildContext context,
    HealthPlatform platform,
  ) async {
    try {
      bool granted = false;

      switch (platform) {
        case HealthPlatform.appleHealth:
          granted = await _appleHealthService?.requestPermission() ?? false;
          break;
        case HealthPlatform.googleFit:
          granted = await _googleFitService?.requestPermission() ?? false;
          break;
        case HealthPlatform.samsungHealth:
          granted = await _samsungHealthService?.requestPermission(context) ?? false;
          break;
      }

      if (granted) {
        _connectedPlatforms.add(platform);
      }

      return granted;
    } catch (e) {
      debugPrint('Error requesting permission for $platform: $e');
      return false;
    }
  }

  /// Request permissions for all supported platforms
  /// Returns: Map of platform to granted status
  Future<Map<HealthPlatform, bool>> requestAllPermissions(
    BuildContext context,
  ) async {
    final Map<HealthPlatform, bool> results = {};

    for (final platform in _supportedPlatforms) {
      results[platform] = await requestPermission(context, platform);
    }

    return results;
  }

  /// Get today's health data from all connected platforms
  /// Aggregates data from all connected platforms
  Future<HealthData?> getTodayData({String? userId}) async {
    if (_connectedPlatforms.isEmpty) {
      debugPrint('No health platforms connected');
      return null;
    }

    try {
      // Default to today's date
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Initialize with empty data
      HealthData? aggregatedData;
      List<HealthData> dataList = [];

      // Fetch data from each connected platform
      for (final platform in _connectedPlatforms) {
        HealthData? data;

        switch (platform) {
          case HealthPlatform.appleHealth:
            data = await _appleHealthService?.getTodayData(
              userId: userId ?? 'guest',
              date: startOfDay,
            );
            break;
          case HealthPlatform.googleFit:
            data = await _googleFitService?.getTodayData(
              userId: userId ?? 'guest',
              date: startOfDay,
            );
            break;
          case HealthPlatform.samsungHealth:
            data = await _samsungHealthService?.getTodayData(
              userId: userId ?? 'guest',
              date: startOfDay,
            );
            break;
        }

        if (data != null) {
          dataList.add(data);
        }
      }

      // Aggregate data from all platforms
      if (dataList.isNotEmpty) {
        aggregatedData = _aggregateHealthData(dataList, startOfDay);
        _healthDataController.add(aggregatedData);
      }

      return aggregatedData;
    } catch (e) {
      debugPrint('Error fetching today\'s health data: $e');
      return null;
    }
  }

  /// Get health data for a specific date range
  Future<List<HealthData>> getDataForRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    if (_connectedPlatforms.isEmpty) {
      return [];
    }

    try {
      List<HealthData> allData = [];

      // Fetch data from Apple Health (most comprehensive on iOS)
      if (Platform.isIOS &&
          _connectedPlatforms.contains(HealthPlatform.appleHealth)) {
        final data = await _appleHealthService?.getDataForRange(
          startDate,
          endDate,
          userId: userId ?? 'guest',
        );
        if (data != null) {
          allData.addAll(data);
        }
      }
      // Fetch data from Google Fit on Android
      else if (Platform.isAndroid &&
          _connectedPlatforms.contains(HealthPlatform.googleFit)) {
        final data = await _googleFitService?.getDataForRange(
          startDate,
          endDate,
          userId: userId ?? 'guest',
        );
        if (data != null) {
          allData.addAll(data);
        }
      }

      return allData;
    } catch (e) {
      debugPrint('Error fetching health data for range: $e');
      return [];
    }
  }

  /// Subscribe to health data updates
  /// Uses platform-specific observers for real-time updates
  /// Returns a StreamSubscription that should be cancelled when done
  StreamSubscription<HealthData> subscribeToUpdates(Function(HealthData) onUpdate) {
    final subscription = _healthDataController.stream.listen(onUpdate);

    // Set up platform-specific observers
    if (Platform.isIOS) {
      _appleHealthService?.subscribeToUpdates((data) {
        _healthDataController.add(data);
      });
    } else if (Platform.isAndroid) {
      _googleFitService?.subscribeToUpdates((data) {
        _healthDataController.add(data);
      });

      _samsungHealthService?.subscribeToUpdates((data) {
        _healthDataController.add(data);
      });
    }

    return subscription;
  }

  /// Unsubscribe from health data updates
  void unsubscribeFromUpdates() {
    if (!_controllerClosed) {
      _healthDataController.close();
      _controllerClosed = true;
    }
  }

  /// Sync data manually (force refresh from all connected platforms)
  Future<HealthData?> syncNow({String? userId}) async {
    return await getTodayData(userId: userId);
  }

  /// Disconnect a health platform
  Future<void> disconnect(HealthPlatform platform) async {
    _connectedPlatforms.remove(platform);

    switch (platform) {
      case HealthPlatform.appleHealth:
        await _appleHealthService?.disconnect();
        break;
      case HealthPlatform.googleFit:
        await _googleFitService?.disconnect();
        break;
      case HealthPlatform.samsungHealth:
        await _samsungHealthService?.disconnect();
        break;
    }
  }

  /// Disconnect all health platforms
  Future<void> disconnectAll() async {
    for (final platform in List.from(_connectedPlatforms)) {
      await disconnect(platform);
    }
  }

  /// Aggregate health data from multiple platforms
  /// When multiple platforms provide data, use the best source for each metric
  HealthData _aggregateHealthData(
    List<HealthData> dataList,
    DateTime date,
  ) {
    // Use non-null values from any platform
    // For steps, use the maximum value
    final stepsList = dataList
        .map((d) => d.steps)
        .where((s) => s != null)
        .cast<int>()
        .toList();
    int? steps = stepsList.isNotEmpty
        ? stepsList.reduce((a, b) => a > b ? a : b)
        : null;

    // For sleep, use the maximum duration
    final sleepDurationList = dataList
        .map((d) => d.sleepDuration)
        .where((s) => s != null)
        .cast<double>()
        .toList();
    double? sleepDuration = sleepDurationList.isNotEmpty
        ? sleepDurationList.reduce((a, b) => a > b ? a : b)
        : null;

    // For heart rate, use the average with overflow protection
    int? avgHeartRate;
    final hrValues =
        dataList.map((d) => d.avgHeartRate).where((h) => h != null).toList();
    if (hrValues.isNotEmpty) {
      // Use double for intermediate sum to prevent overflow
      final sum = hrValues.fold<double>(0.0, (acc, val) => acc + val!.toDouble());
      avgHeartRate = (sum / hrValues.length).round();
    }

    // For calories, use the maximum
    final activeCaloriesList = dataList
        .map((d) => d.activeCalories)
        .where((c) => c != null)
        .cast<int>()
        .toList();
    int? activeCalories = activeCaloriesList.isNotEmpty
        ? activeCaloriesList.reduce((a, b) => a > b ? a : b)
        : null;

    final totalCaloriesList = dataList
        .map((d) => d.totalCaloriesBurned)
        .where((c) => c != null)
        .cast<int>()
        .toList();
    int? totalCalories = totalCaloriesList.isNotEmpty
        ? totalCaloriesList.reduce((a, b) => a > b ? a : b)
        : null;

    // For sleep quality and deep sleep, use the first non-null value
    double? sleepQuality = dataList
        .map((d) => d.sleepQuality)
        .firstWhere((q) => q != null, orElse: () => null);

    double? deepSleepPercent = dataList
        .map((d) => d.deepSleepPercent)
        .firstWhere((d) => d != null, orElse: () => null);

    // Heart rate variability
    int? heartRateVariability = dataList
        .map((d) => d.heartRateVariability)
        .firstWhere((h) => h != null, orElse: () => null);

    // Stress level
    double? stressLevel = dataList
        .map((d) => d.stressLevel)
        .firstWhere((s) => s != null, orElse: () => null);

    // Workouts - combine all workouts from all platforms
    List<Workout> allWorkouts = [];
    for (final data in dataList) {
      if (data.workouts != null) {
        allWorkouts.addAll(data.workouts!);
      }
    }

    return HealthData(
      userId: dataList.first.userId,
      date: date,
      sleepDuration: sleepDuration,
      sleepQuality: sleepQuality,
      deepSleepPercent: deepSleepPercent,
      steps: steps,
      activeCalories: activeCalories,
      totalCaloriesBurned: totalCalories,
      workouts: allWorkouts.isNotEmpty ? allWorkouts : null,
      avgHeartRate: avgHeartRate,
      heartRateVariability: heartRateVariability,
      stressLevel: stressLevel,
    );
  }

  /// Get display name for a platform
  static String getPlatformDisplayName(HealthPlatform platform) {
    switch (platform) {
      case HealthPlatform.appleHealth:
        return 'Apple Health';
      case HealthPlatform.googleFit:
        return 'Google Fit';
      case HealthPlatform.samsungHealth:
        return 'Samsung Health';
    }
  }

  /// Get platform icon
  static String getPlatformIcon(HealthPlatform platform) {
    switch (platform) {
      case HealthPlatform.appleHealth:
        return 'apple_logo'; // Use apple icon
      case HealthPlatform.googleFit:
        return 'fitness_center'; // Use fitness icon
      case HealthPlatform.samsungHealth:
        return 'watch'; // Use watch icon
    }
  }

  /// Check if any platform is connected
  bool get isAnyPlatformConnected => _connectedPlatforms.isNotEmpty;

  /// Dispose resources
  void dispose() {
    unsubscribeFromUpdates();
  }
}

/// Supported health platforms enum
enum HealthPlatform {
  appleHealth,
  googleFit,
  samsungHealth,
}

/// Health permission status
enum HealthPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  notDetermined,
}
