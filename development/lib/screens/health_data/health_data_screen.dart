import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/spacing.dart';
import '../../config/strings.dart';
import '../../models/health_data.dart';
import '../../services/health_service.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/health_data/health_metric_card.dart';

/// Health data screen - Display health metrics from connected apps
/// Now uses real data from HealthService (Apple Health, Google Fit, Samsung Health)
/// Mapped from mockup: 03-health-insights.png
class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final HealthService _healthService = HealthService();

  // Stream subscription for health data updates
  StreamSubscription<HealthData>? _healthDataSubscription;

  // Time filter options
  String _selectedTimeFilter = 'Last 7 days';
  final List<String> _timeFilters = ['Today', 'Last 7 days', 'Last 30 days', 'All time'];

  // Data states
  HealthData? _healthData;
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _healthService.initialize();
    if (!mounted) return;

    // Check if any platform is connected
    setState(() {
      _hasPermission = _healthService.isAnyPlatformConnected;
    });

    if (_hasPermission) {
      await _loadHealthData();
      if (!mounted) return;
      _subscribeToUpdates();
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch today's data
      final todayData = await _healthService.getTodayData(userId: 'current_user');

      // Fetch weekly data if needed
      if (_selectedTimeFilter == 'Last 7 days' ||
          _selectedTimeFilter == 'Last 30 days') {
        final now = DateTime.now();
        final days = _selectedTimeFilter == 'Last 7 days' ? 7 : 30;
        final startDate = now.subtract(Duration(days: days));
        await _healthService.getDataForRange(
          startDate,
          now,
          userId: 'current_user',
        );
      }

      if (!mounted) return;
      setState(() {
        _healthData = todayData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading health data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToUpdates() {
    // Cancel any existing subscription first
    _healthDataSubscription?.cancel();

    _healthDataSubscription = _healthService.subscribeToUpdates((data) {
      if (mounted) {
        setState(() {
          _healthData = data;
        });
      }
    });
  }

  Future<void> _handleSyncNow() async {
    setState(() => _isSyncing = true);

    try {
      final data = await _healthService.syncNow(userId: 'current_user');
      if (!mounted) return;

      setState(() {
        _healthData = data;
        _isSyncing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data != null
                  ? 'Health data synced successfully!'
                  : 'No new data to sync',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error syncing health data: $e');
      if (!mounted) return;

      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sync health data'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleConnectHealthApps() {
    context.push('/health-permissions');
  }

  void _handleSleepDetails() {
    _showDetailsSheet(
      title: 'Sleep Details',
      rows: [
        _DetailRow('Duration', '${(_healthData?.sleepDuration ?? 0).toStringAsFixed(1)} hours'),
        _DetailRow('Sleep Quality', '${((_healthData?.sleepQuality ?? 0) * 100).toStringAsFixed(0)}%'),
        _DetailRow('Deep Sleep', '${(_healthData?.deepSleepPercent ?? 0).toStringAsFixed(0)}%'),
      ],
    );
  }

  void _handleActivityDetails() {
    _showDetailsSheet(
      title: 'Activity Details',
      rows: [
        _DetailRow('Steps', _formatNumber(_healthData?.steps ?? 0)),
        _DetailRow('Active Calories', '${_formatNumber(_healthData?.activeCalories ?? 0)} kcal'),
        _DetailRow('Total Calories Burned', '${_formatNumber(_healthData?.totalCaloriesBurned ?? 0)} kcal'),
        _DetailRow('Workouts', '${_healthData?.workouts?.length ?? 0} today'),
      ],
    );
  }

  void _handleStressDetails() {
    _showDetailsSheet(
      title: 'Stress & Recovery Details',
      rows: [
        _DetailRow('Average Heart Rate', '${_healthData?.avgHeartRate ?? 0} bpm'),
        _DetailRow('HRV', '${_healthData?.heartRateVariability ?? 0} ms'),
        _DetailRow('Stress Score', '${((_healthData?.stressLevel ?? 0) * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  void _showDetailsSheet({required String title, required List<_DetailRow> rows}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline3),
                const SizedBox(height: 16),
                ...rows.map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(row.label, style: AppTextStyles.body),
                          Text(
                            row.value,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildNoDataView();
    }

    if (_healthData == null) {
      return _buildEmptyState();
    }

    return _buildHealthDataView();
  }

  /// No data view - User hasn't connected any health apps yet
  Widget _buildNoDataView() {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            const Text(
              'Connect Your Health Data',
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'Connect to Apple Health, Google Fit, or Samsung Health to see your real health metrics here.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Connect button
            PrimaryButton(
              text: 'Connect Health Apps',
              onPressed: _handleConnectHealthApps,
              width: 280,
            ),
            const SizedBox(height: AppSpacing.md),

            // Skip link
            GestureDetector(
              onTap: () => context.go('/dashboard'),
              child: Text(
                'Skip for now',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state - No health data available yet
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bedtime_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No Health Data Available',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your health data will appear here once it\'s available in your connected health app.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Try Syncing Again',
              onPressed: _handleSyncNow,
              width: 240,
            ),
          ],
        ),
      ),
    );
  }

  /// Main health data view with real metrics
  Widget _buildHealthDataView() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          // Sleep Quality Card
          _buildSleepCard(),
          const SizedBox(height: AppSpacing.md),

          // Activity Level Card
          _buildActivityCard(),
          const SizedBox(height: AppSpacing.md),

          // Stress Levels Card
          _buildStressCard(),
          const SizedBox(height: AppSpacing.lg),

          // Workouts Section (if available)
          if (_healthData?.workouts != null && _healthData!.workouts!.isNotEmpty)
            _buildWorkoutsSection(),
          const SizedBox(height: AppSpacing.lg),

          // Sync Now Button
          PrimaryButton(
            text: _isSyncing ? 'Syncing...' : 'Sync Now',
            onPressed: _isSyncing ? null : _handleSyncNow,
            isLoading: _isSyncing,
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Sleep quality card
  Widget _buildSleepCard() {
    final sleepDuration = _healthData?.sleepDuration ?? 0;
    final sleepQuality = _healthData?.sleepQuality ?? 0;
    final deepSleepPercent = _healthData?.deepSleepPercent ?? 0;

    // Calculate sleep score (0-100)
    final sleepScore = (sleepQuality * 100).toInt();

    return DetailedHealthMetricCard(
      title: AppStrings.sleepQuality,
      iconEmoji: '😴',
      progress: sleepQuality,
      mainValue: sleepScore.toString(),
      mainLabel: 'Sleep Quality Score',
      items: [
        MetricItem(
          label: 'Duration',
          value: '${sleepDuration.toStringAsFixed(1)}h',
        ),
        MetricItem(
          label: 'Deep Sleep',
          value: '${deepSleepPercent.toStringAsFixed(0)}%',
        ),
        MetricItem(
          label: 'Quality',
          value: _getSleepQualityLabel(sleepQuality),
        ),
        MetricItem(
          label: 'Efficiency',
          value: '${(sleepQuality * 100).toInt()}%',
        ),
      ],
      onSeeDetails: _handleSleepDetails,
    );
  }

  /// Activity level card
  Widget _buildActivityCard() {
    final steps = _healthData?.steps ?? 0;
    final activeCalories = _healthData?.activeCalories ?? 0;
    final totalCalories = _healthData?.totalCaloriesBurned ?? 0;
    final workouts = _healthData?.workouts?.length ?? 0;

    // Calculate step progress (10,000 steps = 100%)
    final stepProgress = (steps / 10000).clamp(0.0, 1.0);

    return DetailedHealthMetricCard(
      title: AppStrings.activityLevel,
      iconEmoji: '🏃',
      progress: stepProgress,
      mainValue: _formatNumber(steps),
      mainLabel: 'Steps Today',
      items: [
        MetricItem(
          label: 'Active Calories',
          value: '${_formatNumber(activeCalories)} kcal',
        ),
        MetricItem(
          label: 'Total Burned',
          value: '${_formatNumber(totalCalories)} kcal',
        ),
        MetricItem(
          label: 'Workouts',
          value: '$workouts today',
        ),
      ],
      onSeeDetails: _handleActivityDetails,
    );
  }

  /// Stress levels card
  Widget _buildStressCard() {
    final avgHeartRate = _healthData?.avgHeartRate ?? 0;
    final hrv = _healthData?.heartRateVariability ?? 0;
    final stressLevel = _healthData?.stressLevel ?? 0;

    // Calculate stress score from stress level
    final stressScore = (stressLevel * 100).toInt();

    return DetailedHealthMetricCard(
      title: AppStrings.stressLevels,
      iconEmoji: '💆',
      progress: stressLevel,
      mainValue: stressScore.toString(),
      mainLabel: 'Stress Level',
      items: [
        MetricItem(
          label: 'Avg Heart Rate',
          value: avgHeartRate > 0 ? '$avgHeartRate bpm' : '--',
        ),
        MetricItem(
          label: 'HRV',
          value: hrv > 0 ? '$hrv ms' : '--',
        ),
        MetricItem(
          label: 'Resting HR',
          value: avgHeartRate > 0 ? '${(avgHeartRate * 0.85).toInt()} bpm' : '--',
        ),
      ],
      onSeeDetails: _handleStressDetails,
    );
  }

  /// Workouts section
  Widget _buildWorkoutsSection() {
    return BaseCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🏋️', style: TextStyle(fontSize: 24)),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Today\'s Workouts',
                style: AppTextStyles.headline3,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...(_healthData?.workouts ?? []).map((workout) => _buildWorkoutItem(workout)),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getWorkoutIcon(workout.type),
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${workout.duration} min • ${workout.caloriesBurned} kcal',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWorkoutIcon(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'walking':
        return Icons.directions_walk;
      case 'yoga':
        return Icons.self_improvement;
      case 'strength training':
        return Icons.fitness_center;
      default:
        return Icons.sports_gymnastics;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.healthData,
            style: AppTextStyles.headline3,
          ),
        ],
      ),
      actions: [
        // Time filter dropdown
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _showTimeFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedTimeFilter,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTimeFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time Range',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            ..._timeFilters.map((filter) {
              final isSelected = _selectedTimeFilter == filter;
              return ListTile(
                title: Text(
                  filter,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTimeFilter = filter;
                  });
                  Navigator.pop(context);
                  _loadHealthData();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  String _getSleepQualityLabel(double quality) {
    if (quality >= 0.8) return 'Excellent';
    if (quality >= 0.6) return 'Good';
    if (quality >= 0.4) return 'Fair';
    return 'Poor';
  }

  @override
  void dispose() {
    _healthDataSubscription?.cancel();
    super.dispose();
  }
}


class _DetailRow {
  final String label;
  final String value;

  _DetailRow(this.label, this.value);
}
