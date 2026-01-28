import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';

/// Goal selection screen for onboarding
/// Mapped from mockup: 07-onboarding-goal.png
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  final List<GoalOption> _goals = const [
    GoalOption(
      id: 'weight_loss',
      emoji: '🎯',
      title: AppStrings.weightLoss,
      description: AppStrings.weightLossDescription,
    ),
    GoalOption(
      id: 'build_muscle',
      emoji: '💪',
      title: AppStrings.buildMuscle,
      description: AppStrings.buildMuscleDescription,
    ),
    GoalOption(
      id: 'maintain_weight',
      emoji: '⚖️',
      title: AppStrings.maintainWeight,
      description: AppStrings.maintainWeightDescription,
    ),
    GoalOption(
      id: 'reduce_stress',
      emoji: '😌',
      title: AppStrings.reduceStress,
      description: AppStrings.reduceStressDescription,
    ),
    GoalOption(
      id: 'improve_sleep',
      emoji: '😴',
      title: AppStrings.improveSleep,
      description: AppStrings.improveSleepDescription,
    ),
    GoalOption(
      id: 'get_more_active',
      emoji: '🏃',
      title: AppStrings.getMoreActive,
      description: AppStrings.getMoreActiveDescription,
    ),
  ];

  void _selectGoal(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
  }

  void _handleContinue() {
    if (_selectedGoal != null) {
      context.push('/onboarding/step1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppStrings.whatIsYourGoal,
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: 24),

              // Goal Cards List
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal.id;

                    return _GoalCard(
                      goal: goal,
                      isSelected: isSelected,
                      onTap: () => _selectGoal(goal.id),
                    );
                  },
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: PrimaryButton(
                  text: AppStrings.continueButton,
                  onPressed: _selectedGoal != null ? _handleContinue : null,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Goal card widget with selection border
class _GoalCard extends StatelessWidget {
  final GoalOption goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    Key? key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: BaseCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: AppColors.cardBackground,
          borderRadius: 14, // Slightly smaller to accommodate border
          onTap: onTap,
          child: Row(
            children: [
              // Emoji
              Text(
                goal.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Goal option data model
class GoalOption {
  final String id;
  final String emoji;
  final String title;
  final String description;

  const GoalOption({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
  });
}
