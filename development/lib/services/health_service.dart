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
  StreamController<HealthData>? _healthDataController;

  Stream<HealthData> get healthDataStream {
    _ensureControllerInitialized();
    return _healthDataController!.stream;
  }

  // Supported platforms on this device
  Set<HealthPlatform> _supportedPlatforms = {};
  Set<HealthPlatform> _connectedPlatforms = {};

  // Track subscription state to prevent duplicates
  bool _isSubscribed = false;

  Set<HealthPlatform> get supportedPlatforms => _supportedPlatforms;
  Set<HealthPlatform> get connectedPlatforms => _connectedPlatforms;

  /// Ensure stream controller is initialized
  void _ensureControllerInitialized() {
    if (_healthDataController == null || _healthDataController!.isClosed) {
      _healthDataController = StreamController<HealthData>.broadcast();
    }
  }

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
        _ensureControllerInitialized();
        if (!_healthDataController!.isClosed) {
          _healthDataController!.add(aggregatedData);
        }
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
  void subscribeToUpdates(Function(HealthData) onUpdate) {
    if (_isSubscribed) {
      debugPrint('Already subscribed to health data updates');
      return;
    }

    _ensureControllerInitialized();
    _healthDataController!.stream.listen(onUpdate);
    _isSubscribed = true;

    // Set up platform-specific observers
    if (Platform.isIOS) {
      _appleHealthService?.subscribeToUpdates((data) {
        _ensureControllerInitialized();
        if (!_healthDataController!.isClosed) {
          _healthDataController!.add(data);
        }
      });
    } else if (Platform.isAndroid) {
      _googleFitService?.subscribeToUpdates((data) {
        _ensureControllerInitialized();
        if (!_healthDataController!.isClosed) {
          _healthDataController!.add(data);
        }
      });

      _samsungHealthService?.subscribeToUpdates((data) {
        _ensureControllerInitialized();
        if (!_healthDataController!.isClosed) {
          _healthDataController!.add(data);
        }
      });
    }
  }

  /// Unsubscribe from health data updates
  void unsubscribeFromUpdates() {
    _isSubscribed = false;
    _healthDataController?.close();
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
    final stepValues = dataList.map((d) => d.steps).where((s) => s != null).toList();
    int? steps;
    if (stepValues.isNotEmpty) {
      steps = stepValues.reduce((a, b) => (a! > b!) ? a : b);
    }

    // For sleep, use the maximum duration
    final sleepDurationValues = dataList.map((d) => d.sleepDuration).where((s) => s != null).toList();
    double? sleepDuration;
    if (sleepDurationValues.isNotEmpty) {
      sleepDuration = sleepDurationValues.reduce((a, b) => (a! > b!) ? a : b);
    }

    // For heart rate, use the average
    int? avgHeartRate;
    final hrValues =
        dataList.map((d) => d.avgHeartRate).where((h) => h != null).toList();
    if (hrValues.isNotEmpty) {
      final sum = hrValues.reduce((a, b) => a! + b!)!;
      avgHeartRate = (sum / hrValues.length).round();
    }

    // For calories, use the maximum
    final activeCalValues = dataList.map((d) => d.activeCalories).where((c) => c != null).toList();
    int? activeCalories;
    if (activeCalValues.isNotEmpty) {
      activeCalories = activeCalValues.reduce((a, b) => (a! > b!) ? a : b);
    }

    final totalCalValues = dataList.map((d) => d.totalCaloriesBurned).where((c) => c != null).toList();
    int? totalCalories;
    if (totalCalValues.isNotEmpty) {
      totalCalories = totalCalValues.reduce((a, b) => (a! > b!) ? a : b);
    }

    // For sleep quality and deep sleep, use the first non-null value
    final sleepQualityList = dataList.map((d) => d.sleepQuality).where((q) => q != null).toList();
    double? sleepQuality = sleepQualityList.isNotEmpty ? sleepQualityList.first : null;

    final deepSleepList = dataList.map((d) => d.deepSleepPercent).where((d) => d != null).toList();
    double? deepSleepPercent = deepSleepList.isNotEmpty ? deepSleepList.first : null;

    // Heart rate variability
    final hrvList = dataList.map((d) => d.heartRateVariability).where((h) => h != null).toList();
    int? heartRateVariability = hrvList.isNotEmpty ? hrvList.first : null;

    // Stress level
    final stressList = dataList.map((d) => d.stressLevel).where((s) => s != null).toList();
    double? stressLevel = stressList.isNotEmpty ? stressList.first : null;

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
    _healthDataController.close();
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
