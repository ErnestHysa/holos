import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/food_log/meal_card.dart';
import '../../services/open_food_facts_service.dart';

/// Food log screen - Track daily meals and nutrition
/// Mapped from mockup: 02-nutrition-insights.png
class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final int _maxDailyItems = 5;
  final int _targetCalories = 2000;

  final List<MealEntry> _meals = [
    const MealEntry(
      emoji: '🍳',
      name: 'Overnight oats',
      macros: '450 kcal | P:15g C:60g F:8g',
      time: '8:30 AM',
    ),
    const MealEntry(
      emoji: '🥗',
      name: 'Grilled chicken salad',
      macros: '550 kcal | P:45g C:20g F:25g',
      time: '12:30 PM',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  final Map<int, bool> _mealCheckedStates = {0: false, 1: false};
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _toggleMealCheck(int index) {
    if (index < 0 || index >= _meals.length) return;
    if (!_mealCheckedStates.containsKey(index)) {
      _mealCheckedStates[index] = false;
    }

    setState(() {
      _mealCheckedStates[index] = !(_mealCheckedStates[index] ?? false);
    });
  }

  void _handleBarcodeScan() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add by Barcode'),
        content: TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter barcode number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final barcode = _barcodeController.text.trim();
              if (barcode.isEmpty) return;

              Navigator.pop(dialogContext);

              BarcodeNutritionResult? lookupResult;
              try {
                lookupResult = await _openFoodFactsService.lookupByBarcode(barcode);
              } catch (_) {
                lookupResult = null;
              }

              if (!mounted) return;

              final itemName = lookupResult?.name ?? 'Barcode Item #$barcode';
              final calories = lookupResult?.calories ?? 200;
              final protein = lookupResult?.protein ?? 10;
              final carbs = lookupResult?.carbs ?? 20;
              final fat = lookupResult?.fat ?? 8;

              setState(() {
                _meals.add(
                  MealEntry(
                    emoji: '📦',
                    name: itemName,
                    macros: '$calories kcal | P:${protein}g C:${carbs}g F:${fat}g',
                    time: _currentTimeLabel(),
                  ),
                );
                _mealCheckedStates[_meals.length - 1] = false;
              });

              _barcodeController.clear();

              final sourceLabel = lookupResult == null
                  ? 'Added item with fallback nutrition values'
                  : 'Added nutrition from barcode lookup';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(sourceLabel)),
              );
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _handleQuickAdd() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Add Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Meal name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              caloriesController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
              if (name.isEmpty || calories <= 0) return;

              setState(() {
                _meals.add(
                  MealEntry(
                    emoji: '🍽️',
                    name: name,
                    macros: '$calories kcal | P:0g C:0g F:0g',
                    time: _currentTimeLabel(),
                  ),
                );
                _mealCheckedStates[_meals.length - 1] = false;
              });

              nameController.dispose();
              caloriesController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleAddRecipe() {
    context.push('/ai-suggestion');
  }

  @override
  Widget build(BuildContext context) {
    final itemsCounterText =
        '${AppStrings.todaysLog} ${_meals.length}/$_maxDailyItems${AppStrings.itemsRemaining}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, itemsCounterText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealSectionHeader('Meals'),
            const SizedBox(height: 8),
            ...List.generate(_meals.length, (index) {
              final meal = _meals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MealCard(
                  emoji: meal.emoji,
                  name: meal.name,
                  macros: meal.macros,
                  time: meal.time,
                  isChecked: _mealCheckedStates[index] ?? false,
                  onChanged: (_) => _toggleMealCheck(index),
                ),
              );
            }),
            const SizedBox(height: 20),
            PrimaryButton(
              text: AppStrings.barcodeScan,
              onPressed: _handleBarcodeScan,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
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
                    '${_currentCalories()}/$_targetCalories kcal',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _totalMacros(),
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

  int _extractCalories(String macroText) {
    final match = RegExp(r'^(\d+)\s*kcal').firstMatch(macroText.trim());
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int _extractMacroValue(String macroText, String key) {
    final match = RegExp('$key:(\\d+)g').firstMatch(macroText);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int _currentCalories() {
    return _meals.fold(0, (sum, meal) => sum + _extractCalories(meal.macros));
  }

  String _totalMacros() {
    final protein = _meals.fold(
      0,
      (sum, meal) => sum + _extractMacroValue(meal.macros, 'P'),
    );
    final carbs = _meals.fold(
      0,
      (sum, meal) => sum + _extractMacroValue(meal.macros, 'C'),
    );
    final fat = _meals.fold(
      0,
      (sum, meal) => sum + _extractMacroValue(meal.macros, 'F'),
    );
    return 'P:${protein}g C:${carbs}g F:${fat}g';
  }

  String _currentTimeLabel() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
