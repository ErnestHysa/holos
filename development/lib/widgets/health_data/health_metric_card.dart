import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../common/base_card.dart';
import '../common/progress_bar.dart';

/// Health metric card for displaying individual health metrics
/// Used for: Sleep Quality, Activity Level, Stress Levels
class HealthMetricCard extends StatelessWidget {
  final String title;
  final String iconEmoji;
  final double progress; // 0.0 to 1.0
  final List<MetricItem> items;
  final VoidCallback? onSeeDetails;

  const HealthMetricCard({
    Key? key,
    required this.title,
    required this.iconEmoji,
    required this.progress,
    required this.items,
    this.onSeeDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(progress);

    return BaseCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Text(
                iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headline3,
                ),
              ),
              // See Details link
              if (onSeeDetails != null)
                GestureDetector(
                  onTap: onSeeDetails,
                  child: Text(
                    'See Details →',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ProgressBar(value: progress, width: double.infinity, color: progressColor),
          const SizedBox(height: 16),

          // Metric items
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MetricItemRow(item: item),
              )),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}

/// Metric item row widget
class _MetricItemRow extends StatelessWidget {
  final MetricItem item;

  const _MetricItemRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item.label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          item.value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Metric item data model
class MetricItem {
  final String label;
  final String value;

  const MetricItem({
    required this.label,
    required this.value,
  });
}

/// Detailed health metric card with additional info
/// Used for showing more detailed health information
class DetailedHealthMetricCard extends StatelessWidget {
  final String title;
  final String iconEmoji;
  final double progress;
  final String mainValue;
  final String mainLabel;
  final List<MetricItem> items;
  final VoidCallback? onSeeDetails;

  const DetailedHealthMetricCard({
    Key? key,
    required this.title,
    required this.iconEmoji,
    required this.progress,
    required this.mainValue,
    required this.mainLabel,
    required this.items,
    this.onSeeDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(progress);

    return BaseCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha:0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mainLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // See Details link
              if (onSeeDetails != null)
                GestureDetector(
                  onTap: onSeeDetails,
                  child: Text(
                    'See Details →',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Large value display
          Text(
            mainValue,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ProgressBar(value: progress, width: double.infinity, color: progressColor),
          const SizedBox(height: 16),

          // Additional metric items
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MetricItemRow(item: item),
              )),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}
