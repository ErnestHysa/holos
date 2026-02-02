import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Circular wellness score gauge
/// Mapped from mockup 01-dashboard.png
class CircularScore extends StatelessWidget {
  final int score; // 0 to 100
  final String? trend;
  final double size;

  const CircularScore({
    super.key,
    required this.score,
    this.trend,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final progress = score / 100.0;
    final color = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        // Circle background
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 16,
            backgroundColor: color,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        // Score number + trend
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score/100',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    trend!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
