import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_preference.dart';

/// Notification service for proactive meal suggestions
/// Uses flutter_local_notifications for scheduling
class NotificationService {
  static const String channelId = 'holos_notifications';
  static const String channelName = 'Holos Notifications';
  static const String channelDescription = 'Meal suggestions and reminders from Holos';

  static FlutterLocalNotificationsPlugin? _plugin;
  static bool _initialized = false;

  // Generate unique notification IDs
  static final Random _random = Random.secure();
  static int _generateId() => _random.nextInt(0x7FFFFFFF);

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone database
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _plugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create channel for Android (API 26+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _plugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to appropriate screen
    // This would typically trigger a navigation event via a stream/callback
  }

  /// Parse time string "HH:MM" to TZDateTime for today
  static tz.TZDateTime _parseTimeToDate(String time, [DateTime? baseDate]) {
    final now = baseDate ?? DateTime.now();
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    var scheduledDate = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, hour, minute),
      tz.local,
    );

    // If time has passed today, schedule for tomorrow
    // Compare with the SAME base time we used to create the date
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Schedule wake-up breakfast notification
  static Future<void> scheduleWakeUpNotification({
    required String userName,
    required String mealSuggestion,
    required String time, // Format: "07:00"
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(mealSuggestion),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final scheduledDate = _parseTimeToDate(time);
    final notificationId = _generateId();

    await _plugin!.zonedSchedule(
      notificationId, // Unique notification ID
      '🍳 Time for breakfast, $userName!',
      mealSuggestion,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Schedule lunch notification
  static Future<void> scheduleLunchNotification({
    required String userName,
    required String mealSuggestion,
    required String time, // Format: "12:00"
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(mealSuggestion),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final scheduledDate = _parseTimeToDate(time);
    final notificationId = _generateId();

    await _plugin!.zonedSchedule(
      notificationId, // Unique notification ID
      '🍽️ Lunch time, $userName!',
      mealSuggestion,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule dinner notification
  static Future<void> scheduleDinnerNotification({
    required String userName,
    required String mealSuggestion,
    required String time, // Format: "19:00"
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(mealSuggestion),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final scheduledDate = _parseTimeToDate(time);
    final notificationId = _generateId();

    await _plugin!.zonedSchedule(
      notificationId, // Unique notification ID
      '🍲 Dinner time, $userName!',
      mealSuggestion,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show immediate meal suggestion notification
  static Future<void> showMealSuggestion({
    required String title,
    required String body,
    String payload = 'meal_suggestion',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _plugin!.show(
      _generateId(), // Use unique ID instead of time-based
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _plugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final bool? granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    if (_plugin == null) return;
    await _plugin!.cancelAll();
  }

  /// Cancel specific notification by ID
  static Future<void> cancel(int id) async {
    if (_plugin == null) return;
    await _plugin!.cancel(id);
  }

  /// Get scheduled notifications
  static Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    if (_plugin == null) return [];
    return await _plugin!.pendingNotificationRequests();
  }

  /// Check if current time is within quiet hours
  static bool isQuietHours(NotificationPreference prefs) {
    if (!prefs.quietHoursEnabled) return false;

    final now = DateTime.now();
    final quietStartParts = prefs.quietStart.split(':');
    final quietEndParts = prefs.quietEnd.split(':');

    final quietStartHour = int.parse(quietStartParts[0]);
    final quietEndHour = int.parse(quietEndParts[0]);
    final currentHour = now.hour;

    // Handle overnight quiet hours (e.g., 22:00 to 07:00)
    if (quietStartHour >= quietEndHour) {
      // Quiet hours spans midnight
      return currentHour >= quietStartHour || currentHour < quietEndHour;
    } else {
      // Normal day range
      return currentHour >= quietStartHour && currentHour < quietEndHour;
    }
  }

  /// Schedule all notifications based on user preferences
  static Future<void> scheduleNotificationsFromPreferences(
    NotificationPreference prefs, {
    required String userName,
    Map<String, String>? mealSuggestions,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Cancel existing notifications first
    await cancelAll();

    final suggestions = mealSuggestions ?? {
      'wakeUp': 'Try some overnight oats with berries for a nutritious start!',
      'lunch': 'How about a grilled chicken salad for lunch?',
      'dinner': 'Salmon bowl with vegetables would be great for dinner!',
    };

    // Schedule wake-up notification if enabled
    if (prefs.wakeUpEnabled) {
      await scheduleWakeUpNotification(
        userName: userName,
        mealSuggestion: suggestions['wakeUp']!,
        time: prefs.wakeUpTime,
      );
    }

    // Schedule lunch notification if enabled
    if (prefs.lunchEnabled) {
      await scheduleLunchNotification(
        userName: userName,
        mealSuggestion: suggestions['lunch']!,
        time: prefs.lunchTime,
      );
    }

    // Schedule dinner notification if enabled
    if (prefs.dinnerEnabled) {
      await scheduleDinnerNotification(
        userName: userName,
        mealSuggestion: suggestions['dinner']!,
        time: prefs.dinnerTime,
      );
    }
  }
}
