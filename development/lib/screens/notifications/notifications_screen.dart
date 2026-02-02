import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../models/notification_preference.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Notifications screen - Proactive meal suggestions
/// Mapped from mockup: 12-notifications.png
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock notifications data
  final List<NotificationItem> _notifications = [
    const NotificationItem(
      id: 'notif1',
      time: '8:30 AM',
      type: 'Wake-up Breakfast',
      mealName: 'Overnight Oats',
      emoji: '🍳',
      description: 'Quick and nutritious breakfast to start your day',
      macros: '450 kcal | P:15g C:60g F:8g',
      isRead: false,
    ),
    const NotificationItem(
      id: 'notif2',
      time: '12:00 PM',
      type: 'Lunch Suggestion',
      mealName: 'Grilled Chicken Salad',
      emoji: '🥗',
      description: 'Light and fresh for afternoon energy',
      macros: '550 kcal | P:45g C:20g F:25g',
      isRead: false,
    ),
    const NotificationItem(
      id: 'notif3',
      time: '7:00 PM',
      type: 'Dinner Suggestion',
      mealName: 'Salmon Bowl',
      emoji: '🍲',
      description: 'Recovery meal after your evening workout',
      macros: '700 kcal | P:40g C:35g F:30g',
      isRead: false,
    ),
  ];

  // User notification preferences (mock for now)
  late final NotificationPreference _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = NotificationPreference(userId: 'current-user');
  }

  void _markAsRead(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications.clear();
    });
  }

  void _handleAddToLog(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.mealName} added to your log!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => context.push('/food-log'),
        ),
      ),
    );
  }

  void _handleViewRecipe(String mealName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mealName recipe details coming soon!')),
    );
  }

  void _openNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildNotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Notifications',
        style: AppTextStyles.headline3,
      ),
      centerTitle: true,
      actions: [
        if (_notifications.isNotEmpty)
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: _openNotificationSettings,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Meal suggestions will appear here',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Configure Notifications',
              onPressed: _openNotificationSettings,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationCard(
          notification: notification,
          onAddToLog: () => _handleAddToLog(notification),
          onViewRecipe: () => _handleViewRecipe(notification.mealName),
          onDismiss: () => _markAsRead(notification.id),
        );
      },
    );
  }

  Widget _buildNotificationSettingsSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notification Settings',
                    style: AppTextStyles.headline3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Wake-up notification
              _buildToggleRow(
                'Wake-up Breakfast',
                '7:00 AM',
                _preferences.wakeUpEnabled,
                (value) => setModalState(() {
                  _preferences = _preferences.copyWith(wakeUpEnabled: value);
                }),
              ),
              const SizedBox(height: 16),

              // Lunch notification
              _buildToggleRow(
                'Lunch Suggestion',
                '12:00 PM',
                _preferences.lunchEnabled,
                (value) => setModalState(() {
                  _preferences = _preferences.copyWith(lunchEnabled: value);
                }),
              ),
              const SizedBox(height: 16),

              // Dinner notification
              _buildToggleRow(
                'Dinner Suggestion',
                '7:00 PM',
                _preferences.dinnerEnabled,
                (value) => setModalState(() {
                  _preferences = _preferences.copyWith(dinnerEnabled: value);
                }),
              ),
              const SizedBox(height: 16),

              // Daily limit
              const Text(
                'Daily Limit',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (index) {
                  final value = index + 1;
                  final isSelected = _preferences.dailyLimit == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text('$value'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            _preferences = _preferences.copyWith(dailyLimit: value);
                          });
                        }
                      },
                      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                      labelStyle: AppTextStyles.caption,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Save Settings',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved!')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleRow(
    String title,
    String time,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primaryGreen,
        ),
      ],
    );
  }
}

/// Notification card widget
class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onAddToLog;
  final VoidCallback onViewRecipe;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onAddToLog,
    required this.onViewRecipe,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with time and dismiss
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notification.type,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                notification.time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Meal suggestion card content
          Row(
            children: [
              Text(
                notification.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.mealName,
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.macros,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Add to Log',
                  onPressed: onAddToLog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'View Recipe',
                  onPressed: onViewRecipe,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Notification item data model
class NotificationItem {
  final String id;
  final String time;
  final String type;
  final String mealName;
  final String emoji;
  final String description;
  final String macros;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.time,
    required this.type,
    required this.mealName,
    required this.emoji,
    required this.description,
    required this.macros,
    required this.isRead,
  });
}
