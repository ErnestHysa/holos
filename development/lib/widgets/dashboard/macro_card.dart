import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../common/progress_bar.dart';
import '../common/base_card.dart';

/// Macro progress card (Protein, Carbs, Fat)
/// Mapped from mockup: Shows nutrient with current/target and progress
class MacroCard extends StatelessWidget {
  final String label;
  final String current;
  final String target;
  final double progress;

  const MacroCard({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(
            '$current/$target',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ProgressBar(value: progress, width: 75, height: 6),
        ],
      ),
    );
  }
}
