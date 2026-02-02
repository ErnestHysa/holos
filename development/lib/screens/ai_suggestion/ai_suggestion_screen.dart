import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/spacing.dart';
import '../../config/strings.dart';
import '../../models/health_data.dart';
import '../../services/health_service.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/ai_suggestion/meal_suggestion_card.dart';

/// AI Suggestion screen - Personalized meal recommendations
/// Now uses real health data from HealthService for contextual suggestions
/// Mapped from mockup: 04-recipe-card.png
class AiSuggestionScreen extends StatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  State<AiSuggestionScreen> createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends State<AiSuggestionScreen> {
  final HealthService _healthService = HealthService();

  // Health data for contextual suggestions
  HealthData? _healthData;
  bool _isLoading = true;
  bool _isGeneratingSuggestion = false;

  // AI meal suggestion data (mocked for now, will be from AI service)
  MealSuggestion? _suggestion;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _healthService.initialize();

    // Fetch health data for context
    final healthData =
        await _healthService.getTodayData(userId: 'current_user');

    setState(() {
      _healthData = healthData;
      _isLoading = false;
    });

    // Generate AI suggestion based on health data
    _generateContextualSuggestion();
  }

  Future<void> _generateContextualSuggestion() async {
    setState(() => _isGeneratingSuggestion = true);

    try {
      // Generate contextual message based on health data
      final contextMessage = _generateContextMessage();

      // Generate meal suggestion (mocked for now - will use GeminiService)
      final suggestion = _generateMealSuggestion(contextMessage);

      setState(() {
        _suggestion = suggestion;
        _isGeneratingSuggestion = false;
      });
    } catch (e) {
      debugPrint('Error generating suggestion: $e');
      setState(() => _isGeneratingSuggestion = false);
    }
  }

  /// Generate contextual message based on health data
  String _generateContextMessage() {
    if (_healthData == null) {
      return 'Here\'s a healthy meal suggestion for you:';
    }

    final steps = _healthData?.steps ?? 0;
    final calories = _healthData?.activeCalories ?? 0;
    final sleepDuration = _healthData?.sleepDuration ?? 0;
    final sleepQuality = _healthData?.sleepQuality ?? 0;
    final workouts = _healthData?.workouts?.length ?? 0;

    // Context: Post-workout recovery
    if (workouts > 0 || calories > 500) {
      final burned = workouts > 0
          ? (_healthData!.workouts!.fold(0, (sum, w) => sum + w.caloriesBurned))
          : calories;
      return 'Great job! You burned $burned calories today. Here\'s a recovery meal:';
    }

    // Context: Poor sleep
    if (sleepDuration < 6 || sleepQuality < 0.5) {
      return 'You didn\'t get enough sleep last night. Here\'s a meal to help you recover:';
    }

    // Context: Active day
    if (steps > 8000) {
      return 'Active day! You\'ve walked ${_formatNumber(steps)} steps. Here\'s a nutritious meal:';
    }

    // Context: Low activity
    if (steps < 3000) {
      return 'Keep moving! You\'ve only walked ${_formatNumber(steps)} steps today. Here\'s a light meal:';
    }

    // Default context
    return 'Here\'s a personalized meal suggestion for you:';
  }

  /// Generate meal suggestion (mocked - will use GeminiService in production)
  MealSuggestion _generateMealSuggestion(String contextMessage) {
    // Get context-specific meal
    final steps = _healthData?.steps ?? 0;
    final calories = _healthData?.activeCalories ?? 0;
    final workouts = _healthData?.workouts?.length ?? 0;

    // Post-workout meal
    if (workouts > 0 || calories > 500) {
      return MealSuggestion(
        mealName: 'Grilled Salmon Bowl',
        emoji: '🍲',
        timeOfDay: _getTimeOfDay(),
        contextMessage: contextMessage,
        description:
            'High-protein recovery meal with omega-3s for muscle repair. Grilled salmon with quinoa, roasted veggies, and lemon-herb dressing.',
        macros: MealMacros(
          calories: 700,
          protein: 45,
          carbs: 40,
          fat: 28,
        ),
      );
    }

    // Light meal for low activity days
    if (steps < 3000) {
      return MealSuggestion(
        mealName: 'Mediterranean Salad',
        emoji: '🥗',
        timeOfDay: _getTimeOfDay(),
        contextMessage: contextMessage,
        description:
            'Light and refreshing. Mixed greens with cherry tomatoes, cucumber, olives, feta cheese, and a balsamic vinaigrette.',
        macros: MealMacros(
          calories: 380,
          protein: 18,
          carbs: 20,
          fat: 24,
        ),
      );
    }

    // Poor sleep recovery meal
    if ((_healthData?.sleepDuration ?? 0) < 6) {
      return MealSuggestion(
        mealName: 'Turkey & Avocado Wrap',
        emoji: '🌯',
        timeOfDay: _getTimeOfDay(),
        contextMessage: contextMessage,
        description:
            'Tryptophan-rich turkey with healthy fats to help you rest better. Whole grain wrap with turkey, avocado, lettuce, and tomatoes.',
        macros: MealMacros(
          calories: 520,
          protein: 35,
          carbs: 38,
          fat: 22,
        ),
      );
    }

    // Default balanced meal
    return MealSuggestion(
      mealName: 'Chicken Buddha Bowl',
      emoji: '🍜',
      timeOfDay: _getTimeOfDay(),
      contextMessage: contextMessage,
      description:
          'Balanced nutrition for sustained energy. Grilled chicken with brown rice, edamame, pickled carrots, and sesame ginger sauce.',
      macros: MealMacros(
        calories: 580,
        protein: 38,
        carbs: 55,
        fat: 20,
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 14) return 'lunch';
    if (hour < 17) return 'snack';
    return 'dinner';
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  void _handleAddToLog() {
    if (_suggestion == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_suggestion!.mealName} added to your log!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => context.push('/food-log'),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.push('/food-log');
      }
    });
  }

  void _handleViewRecipe() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe details coming soon!')),
    );
  }

  void _handleRefresh() {
    _generateContextualSuggestion();
  }

  String _formatMacros() {
    if (_suggestion == null) return '';
    final macros = _suggestion!.macros;
    return '${macros.calories} kcal | P:${macros.protein}g C:${macros.carbs}g F:${macros.fat}g';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_suggestion == null || _isGeneratingSuggestion) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
            SizedBox(height: AppSpacing.md),
            Text('Generating personalized suggestion...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with health context
          _buildHealthContextHeader(),
          const SizedBox(height: AppSpacing.lg),

          // AI-powered badge
          _buildAIBadge(),
          const SizedBox(height: AppSpacing.lg),

          // Meal Suggestion Card
          MealSuggestionCard(
            name: '${_suggestion!.emoji} ${_suggestion!.mealName}',
            macros: _formatMacros(),
            description: _suggestion!.description,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Add to Log',
                  onPressed: _handleAddToLog,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SecondaryButton(
                  text: 'View Recipe',
                  onPressed: _handleViewRecipe,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Refresh button
          Center(
            child: GestureDetector(
              onTap: _handleRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Get new suggestion',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Build header with health context
  Widget _buildHealthContextHeader() {
    if (_healthData == null) {
      return Row(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.timeForMeal,
              style: AppTextStyles.headline3.copyWith(fontSize: 22),
            ),
          ),
        ],
      );
    }

    final steps = _healthData?.steps ?? 0;
    final calories = _healthData?.activeCalories ?? 0;
    final sleep = _healthData?.sleepDuration ?? 0;

    return BaseCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Your Wellness Snapshot',
                  style: AppTextStyles.headline3.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.directions_walk,
                value: _formatNumber(steps),
                label: 'steps',
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildStatChip(
                icon: Icons.local_fire_department,
                value: '$calories',
                label: 'kcal burned',
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildStatChip(
                icon: Icons.bedtime,
                value: '${sleep.toStringAsFixed(1)}h',
                label: 'sleep',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.label.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Build AI-powered badge
  Widget _buildAIBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AI-Powered Suggestion',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'AI Suggestion',
            style: AppTextStyles.headline3,
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (_healthData != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: _handleRefresh,
          ),
      ],
    );
  }
}

/// Meal suggestion data model
class MealSuggestion {
  final String mealName;
  final String emoji;
  final String timeOfDay;
  final String contextMessage;
  final String description;
  final MealMacros macros;

  MealSuggestion({
    required this.mealName,
    required this.emoji,
    required this.timeOfDay,
    required this.contextMessage,
    required this.description,
    required this.macros,
  });
}

/// Meal macros data model
class MealMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MealMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
