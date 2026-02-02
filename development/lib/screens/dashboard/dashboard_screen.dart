import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/circular_score.dart';
import '../../widgets/dashboard/snapshot_card.dart';
import '../../widgets/dashboard/macro_card.dart';

/// Dashboard screen - Main app entry point
/// Mapped from mockup: 01-dashboard.png
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Wellness score data
  final int _wellnessScore = 82;
  final String _scoreTrend = '↑ 5 points this week';

  // Today's snapshot data
  final List<SnapshotMetric> _snapshotMetrics = const [
    SnapshotMetric(label: 'Sleep', value: '7h', progress: 0.90),
    SnapshotMetric(label: 'Nutrition', value: '60%', progress: 0.60),
    SnapshotMetric(label: 'Activity', value: '8.5k', progress: 0.85),
    SnapshotMetric(label: 'Stress', value: '72', progress: 0.72),
  ];

  // Macros progress data
  final List<MacroMetric> _macroMetrics = const [
    MacroMetric(label: 'Protein', current: '90g', target: '150g', progress: 0.60),
    MacroMetric(label: 'Carbs', current: '120g', target: '200g', progress: 0.60),
    MacroMetric(label: 'Fat', current: '45g', target: '70g', progress: 0.64),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Wellness Score Hero
            CircularScore(
              score: _wellnessScore,
              trend: _scoreTrend,
              size: 200,
            ),
            const SizedBox(height: 32),

            // Today's Snapshot Section
            _buildSectionHeader(AppStrings.todaysSnapshot),
            const SizedBox(height: 16),
            BaseCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: _snapshotMetrics.map((metric) {
                  return SnapshotCard(
                    label: metric.label,
                    value: metric.value,
                    progress: metric.progress,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Macros Progress Section
            _buildSectionHeader(AppStrings.macrosProgress),
            const SizedBox(height: 16),
            Row(
              children: _macroMetrics.map((macro) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: macro != _macroMetrics.last ? 12 : 0,
                    ),
                    child: MacroCard(
                      label: macro.label,
                      current: macro.current,
                      target: macro.target,
                      progress: macro.progress,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: AppStrings.logFood,
                    onPressed: () => context.push('/food-log'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SecondaryButton(
                    text: AppStrings.aiSuggestion,
                    onPressed: () => context.push('/ai-suggestion'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            AppStrings.appName,
            style: AppTextStyles.headline3,
          ),
        ],
      ),
      actions: [
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to profile/settings
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryGreen,
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.headline3,
      ),
    );
  }
}

/// Snapshot metric data model
class SnapshotMetric {
  final String label;
  final String value;
  final double progress;

  const SnapshotMetric({
    required this.label,
    required this.value,
    required this.progress,
  });
}

/// Macro metric data model
class MacroMetric {
  final String label;
  final String current;
  final String target;
  final double progress;

  const MacroMetric({
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
  });
}
