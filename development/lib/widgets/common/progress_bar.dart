import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';

/// Progress bar widget for health metrics and macros
/// Mapped from mockup: Shows horizontal progress with color coding
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String? label;
  final double? width;
  final double? height;
  final Color? color;

  const ProgressBar({
    Key? key,
    required this.value,
    this.label,
    this.width = 280,
    this.height = 12,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? _getColorForValue(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: AppTextStyles.caption,
          ),
        const SizedBox(height: 4),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.progressBackground,
            borderRadius: BorderRadius.circular(height! / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height! / 2),
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: progressColor),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 0.8) return AppColors.success;    // Good: 80%+
    if (value >= 0.6) return AppColors.warning;  // Warning: 60-79%
    return AppColors.error;    // Poor: <60%
  }
}
