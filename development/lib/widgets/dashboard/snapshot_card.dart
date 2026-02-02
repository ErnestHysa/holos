import 'package:flutter/material.dart';
import '../../config/fonts.dart';
import '../common/progress_bar.dart';

/// Snapshot card for dashboard (Sleep, Nutrition, Activity, Stress)
/// Mapped from mockup: Shows metric with label, value, and progress
class SnapshotCard extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const SnapshotCard({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: ProgressBar(value: progress, width: 200)),
          SizedBox(
            width: 50,
            child: Text(value, style: AppTextStyles.headline3),
          ),
        ],
      ),
    );
  }
}
