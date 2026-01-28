import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../common/base_card.dart';

/// Meal suggestion card for AI recommendations
/// Mapped from mockup 04-recipe-card.png
class MealSuggestionCard extends StatelessWidget {
  final String? image;
  final String name;
  final String macros;
  final String description;

  const MealSuggestionCard({
    Key? key,
    this.image,
    required this.name,
    required this.macros,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: image != null
                  ? Image.asset(image!)
                  : Text(
                      '[Food Image]',
                      style: AppTextStyles.caption,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headline3.copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Text(macros, style: AppTextStyles.caption),
                const SizedBox(height: 12),
                Text(description, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
