import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../common/base_card.dart';

/// Meal card for food log (Breakfast, Lunch, Dinner, Snacks)
/// Mapped from mockup 02-nutrition-insights.png
class MealCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String macros;
  final String time;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const MealCard({
    Key? key,
    required this.emoji,
    required this.name,
    required this.macros,
    required this.time,
    this.isChecked = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: AppTextStyles.headline3),
                    Text(
                      time,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(macros, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}
