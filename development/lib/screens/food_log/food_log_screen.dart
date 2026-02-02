import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/food_log/meal_card.dart';

/// Food log screen - Track daily meals and nutrition
/// Mapped from mockup: 02-nutrition-insights.png
class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  // Daily tracking limits
  final int _maxDailyItems = 5;
  final int _targetCalories = 2000;

  // Today's meals data
  final List<MealEntry> _meals = const [
    MealEntry(
      emoji: '🍳',
      name: 'Overnight oats',
      macros: '450 kcal | P:15g C:60g F:8g',
      time: '8:30 AM',
    ),
    MealEntry(
      emoji: '🥗',
      name: 'Grilled chicken salad',
      macros: '550 kcal | P:45g C:20g F:25g',
      time: '12:30 PM',
    ),
  ];

  // Today's totals
  final int _currentCalories = 1000;
  final String _totalMacros = 'P:60g C:80g F:33g';

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Meal checkbox states
  final Map<int, bool> _mealCheckedStates = {0: false, 1: false};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMealCheck(int index) {
    setState(() {
      _mealCheckedStates[index] = !(_mealCheckedStates[index] ?? false);
    });
  }

  void _handleBarcodeScan() {
    // TODO: Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode scanning coming soon!')),
    );
  }

  void _handleQuickAdd() {
    // TODO: Implement quick add dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick add coming soon!')),
    );
  }

  void _handleAddRecipe() {
    // TODO: Implement add recipe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add recipe coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItems = _meals.length;
    final itemsCounterText = '${AppStrings.todaysLog} $currentItems/$_maxDailyItems${AppStrings.itemsRemaining}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, itemsCounterText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meals Section Header
            _buildMealSectionHeader('Breakfast'),
            const SizedBox(height: 8),

            // Breakfast Meal Card
            MealCard(
              emoji: _meals[0].emoji,
              name: _meals[0].name,
              macros: _meals[0].macros,
              time: _meals[0].time,
              isChecked: _mealCheckedStates[0] ?? false,
              onChanged: (_) => _toggleMealCheck(0),
            ),
            const SizedBox(height: 24),

            // Lunch Section Header
            _buildMealSectionHeader('Lunch'),
            const SizedBox(height: 8),

            // Lunch Meal Card
            MealCard(
              emoji: _meals[1].emoji,
              name: _meals[1].name,
              macros: _meals[1].macros,
              time: _meals[1].time,
              isChecked: _mealCheckedStates[1] ?? false,
              onChanged: (_) => _toggleMealCheck(1),
            ),
            const SizedBox(height: 32),

            // Barcode Scan Button
            PrimaryButton(
              text: AppStrings.barcodeScan,
              onPressed: _handleBarcodeScan,
              width: double.infinity,
            ),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchFood,
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: AppStrings.quickAdd,
                    onPressed: _handleQuickAdd,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SecondaryButton(
                    text: AppStrings.addRecipe,
                    onPressed: _handleAddRecipe,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Today's Total Card
            BaseCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.todaysTotal,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_currentCalories/$_targetCalories kcal',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _totalMacros,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String itemsCounterText) {
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
            AppStrings.todaysLog,
            style: AppTextStyles.headline3,
          ),
        ],
      ),
      actions: [
        // Items counter badge
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_meals.length}/$_maxDailyItems',
            style: AppTextStyles.label.copyWith(
              color: AppColors.accentAmber,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSectionHeader(String mealType) {
    return Text(
      mealType,
      style: AppTextStyles.headline3,
    );
  }
}

/// Meal entry data model for food log
class MealEntry {
  final String emoji;
  final String name;
  final String macros;
  final String time;

  const MealEntry({
    required this.emoji,
    required this.name,
    required this.macros,
    required this.time,
  });
}
