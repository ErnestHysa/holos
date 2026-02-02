import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../models/meal_plan.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Meal planner screen - Adaptive meal planning for the week
/// Mapped from mockup: 13-meal-schedule.png
class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  // Selected date (today by default)
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  // Mock meal plans for the week
  final Map<DateTime, MealPlan> _weeklyPlans = {};

  @override
  void initState() {
    super.initState();
    _initializeMockPlans();
  }

  void _initializeMockPlans() {
    final today = DateUtils.dateOnly(DateTime.now());
    final tomorrow = DateUtils.dateOnly(today.add(const Duration(days: 1)));

    // Create today's plan
    _weeklyPlans[today] = MealPlan(
      id: 'plan-${today.millisecondsSinceEpoch}',
      userId: 'current-user',
      date: today,
      meals: [
        PlannedMeal(
          id: 'breakfast-${today.millisecondsSinceEpoch}',
          mealType: AppStrings.breakfast,
          name: 'Overnight Oats',
          emoji: '🍳',
          macros: {'calories': 450, 'protein': 15, 'carbs': 60, 'fat': 8},
          time: '08:00',
          isAIgenerated: false,
        ),
        PlannedMeal(
          id: 'lunch-${today.millisecondsSinceEpoch}',
          mealType: AppStrings.lunch,
          name: 'Grilled Chicken Salad',
          emoji: '🥗',
          macros: {'calories': 550, 'protein': 45, 'carbs': 20, 'fat': 25},
          time: '12:30',
          isAIgenerated: false,
        ),
        PlannedMeal(
          id: 'dinner-${today.millisecondsSinceEpoch}',
          mealType: AppStrings.dinner,
          name: 'Salmon Bowl',
          emoji: '🍲',
          macros: {'calories': 700, 'protein': 40, 'carbs': 35, 'fat': 30},
          time: '19:00',
          isAIgenerated: true,
        ),
      ],
      totalCalories: 1700,
      totalProtein: 100.0,
      totalCarbs: 115.0,
      totalFat: 63.0,
    );

    // Create tomorrow's plan
    _weeklyPlans[tomorrow] = MealPlan(
      id: 'plan-${tomorrow.millisecondsSinceEpoch}',
      userId: 'current-user',
      date: tomorrow,
      meals: [
        PlannedMeal(
          id: 'breakfast-${tomorrow.millisecondsSinceEpoch}',
          mealType: AppStrings.breakfast,
          name: 'Greek Yogurt Parfait',
          emoji: '🥣',
          macros: {'calories': 380, 'protein': 20, 'carbs': 45, 'fat': 10},
          time: '08:00',
          isAIgenerated: true,
        ),
        PlannedMeal(
          id: 'lunch-${tomorrow.millisecondsSinceEpoch}',
          mealType: AppStrings.lunch,
          name: 'Turkey Wrap',
          emoji: '🌯',
          macros: {'calories': 620, 'protein': 35, 'carbs': 55, 'fat': 22},
          time: '12:30',
          isAIgenerated: true,
        ),
        PlannedMeal(
          id: 'dinner-${tomorrow.millisecondsSinceEpoch}',
          mealType: AppStrings.dinner,
          name: 'Vegetable Stir Fry',
          emoji: '🥘',
          macros: {'calories': 580, 'protein': 18, 'carbs': 65, 'fat': 18},
          time: '19:00',
          isAIgenerated: true,
        ),
      ],
      totalCalories: 1580,
      totalProtein: 73.0,
      totalCarbs: 165.0,
      totalFat: 50.0,
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateUtils.dateOnly(date);
    });
  }

  void _planNewDay() {
    setState(() {
      DateTime nextDate = _selectedDate;

      while (_weeklyPlans.containsKey(nextDate)) {
        nextDate = DateUtils.dateOnly(nextDate.add(const Duration(days: 1)));
      }

      _weeklyPlans[nextDate] = MealPlan(
        id: 'plan-${nextDate.millisecondsSinceEpoch}',
        userId: 'current-user',
        date: nextDate,
        meals: [
          PlannedMeal(
            id: 'breakfast-${nextDate.millisecondsSinceEpoch}',
            mealType: AppStrings.breakfast,
            macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
            time: '08:00',
          ),
          PlannedMeal(
            id: 'lunch-${nextDate.millisecondsSinceEpoch}',
            mealType: AppStrings.lunch,
            macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
            time: '12:30',
          ),
          PlannedMeal(
            id: 'dinner-${nextDate.millisecondsSinceEpoch}',
            mealType: AppStrings.dinner,
            macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
            time: '19:00',
          ),
        ],
        totalCalories: 0,
        totalProtein: 0.0,
        totalCarbs: 0.0,
        totalFat: 0.0,
      );

      _selectedDate = nextDate;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _editMeal(PlannedMeal meal) {
    final nameController = TextEditingController(text: meal.name);
    final timeController = TextEditingController(text: meal.time ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Meal',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Save',
                    onPressed: () {
                      if (!mounted) return;

                      final plan = _weeklyPlans[_selectedDate];
                      if (plan == null) {
                        Navigator.pop(context);
                        return;
                      }

                      final index =
                          plan.meals.indexWhere((m) => m.id == meal.id);
                      if (index != -1) {
                        setState(() {
                          plan.meals[index] = meal.copyWith(
                            name: nameController.text,
                            time: timeController.text,
                          );
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      nameController.dispose();
      timeController.dispose();
    });
  }

  void _generateAISuggestions() {
    // TODO: Open AI suggestion screen
    context.push('/ai-suggestion');
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _weeklyPlans[_selectedDate] ?? _createEmptyPlan(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Week selector (horizontal calendar)
            _buildWeekSelector(),
            const SizedBox(height: 24),

            // Day summary card
            _buildDaySummaryCard(currentPlan),
            const SizedBox(height: 24),

            // Meals list
            _buildMealsList(currentPlan),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'AI Suggestions',
                    onPressed: _generateAISuggestions,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Plan New Day',
                    onPressed: _planNewDay,
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Meal Planner',
        style: AppTextStyles.headline3,
      ),
      centerTitle: true,
    );
  }

  Widget _buildWeekSelector() {
    final today = DateUtils.dateOnly(DateTime.now());
    final weekDays = _getWeekDays(today);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final dayDate = weekDays[index];
          final isSelected = _isSameDay(dayDate, _selectedDate);
          final hasPlan = _weeklyPlans.containsKey(dayDate);
          final isPastDay = dayDate.isBefore(today);

          return GestureDetector(
            onTap: isPastDay ? null : () => _selectDate(dayDate),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(dayDate),
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayDate.day}',
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasPlan)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySummaryCard(MealPlan plan) {
    final completion = plan.completionPercentage;

    return BaseCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(plan.date),
                style: AppTextStyles.headline3,
              ),
              Text(
                '${(completion * 100).toInt()}% Planned',
                style: AppTextStyles.caption.copyWith(
                  color: completion >= 1.0
                      ? AppColors.success
                      : AppColors.accentAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _macroSummary(
                  label: 'Calories',
                  current: plan.totalCalories,
                  target: 2000,
                  unit: 'kcal',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _macroSummary(
                  label: 'Protein',
                  current: plan.totalProtein.toInt(),
                  target: 150,
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(MealPlan plan) {
    final mealsByType = {
      AppStrings.breakfast: plan.meals.where((m) => m.mealType == AppStrings.breakfast).toList(),
      AppStrings.lunch: plan.meals.where((m) => m.mealType == AppStrings.lunch).toList(),
      AppStrings.dinner: plan.meals.where((m) => m.mealType == AppStrings.dinner).toList(),
      AppStrings.snack: plan.meals.where((m) => m.mealType == AppStrings.snack).toList(),
    };

    return Column(
      children: [
        ...mealsByType.entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              entry.key,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
        ...plan.meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(PlannedMeal meal) {
    final isPlanned = meal.isPlanned;
    final isAI = meal.isAIgenerated;

    return GestureDetector(
      onTap: () => _editMeal(meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAI && isPlanned
                ? AppColors.secondaryBlue.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji
              Text(
                isPlanned ? (meal.emoji ?? '🍽️') : '➕',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPlanned ? meal.name : 'No meal planned',
                      style: AppTextStyles.headline3.copyWith(
                        color: isPlanned
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isPlanned) ...[
                      const SizedBox(height: 4),
                      Text(
                        meal.formattedMacros,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (meal.time != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          meal.time!,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Status icons
              if (isPlanned && isAI)
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.secondaryBlue.withValues(alpha: 0.7),
                ),
              if (!isPlanned)
                const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _macroSummary({required String label, required int current, required int target}) {
=======
  Widget _MacroSummary({
    required String label,
    required int current,
    required int target,
    required String unit,
  }) {
>>>>>>> 98a8bb278a9e1a0ebde90c77b8804772a13d699f
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$target $unit',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.progressBackground,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: _getColorForProgress(progress),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(double value) {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  List<DateTime> _getWeekDays(DateTime today) {
    final baseDate = DateUtils.dateOnly(today);
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  MealPlan _createEmptyPlan(DateTime date) {
    final planDate = DateUtils.dateOnly(date);

    return MealPlan(
      id: 'plan-${planDate.millisecondsSinceEpoch}',
      userId: 'current-user',
      date: planDate,
      meals: [
        PlannedMeal(
          id: 'breakfast-${planDate.millisecondsSinceEpoch}',
          mealType: AppStrings.breakfast,
          macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
          time: '08:00',
        ),
        PlannedMeal(
          id: 'lunch-${planDate.millisecondsSinceEpoch}',
          mealType: AppStrings.lunch,
          macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
          time: '12:30',
        ),
        PlannedMeal(
          id: 'dinner-${planDate.millisecondsSinceEpoch}',
          mealType: AppStrings.dinner,
          macros: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
          time: '19:00',
        ),
      ],
      totalCalories: 0,
      totalProtein: 0.0,
      totalCarbs: 0.0,
      totalFat: 0.0,
    );
  }
}
