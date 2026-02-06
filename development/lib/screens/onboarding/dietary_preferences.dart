import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/app_state_service.dart';

/// Dietary preferences screen for onboarding step 2
/// Mapped from mockup: 17-onboarding-step2.png
class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  final AppStateService _appStateService = AppStateService();

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final savedRestrictions = await _appStateService.getDietaryRestrictions();
    final savedAllergens = await _appStateService.getAllergens();

    if (!mounted) return;

    setState(() {
      _selectedRestrictions
        ..clear()
        ..addAll(
          DietaryRestriction.values.where((value) => savedRestrictions.contains(value.name)),
        );
      _selectedAllergens
        ..clear()
        ..addAll(
          Allergen.values.where((value) => savedAllergens.contains(value.name)),
        );

      _isNoneSelectedForRestrictions = _selectedRestrictions.isEmpty;
      _isNoneSelectedForAllergens = _selectedAllergens.isEmpty;
    });
  }

  // Selected dietary restrictions (multiple selection allowed)
  final Set<DietaryRestriction> _selectedRestrictions = {};

  // Selected allergens (multiple selection allowed)
  final Set<Allergen> _selectedAllergens = {};

  // Track if "None" is selected (meaning no restrictions)
  bool _isNoneSelectedForRestrictions = false;
  bool _isNoneSelectedForAllergens = false;

  void _toggleRestriction(DietaryRestriction restriction) {
    setState(() {
      if (_selectedRestrictions.contains(restriction)) {
        _selectedRestrictions.remove(restriction);
      } else {
        _selectedRestrictions.add(restriction);
        _isNoneSelectedForRestrictions = false;
      }
    });
  }

  void _toggleAllergen(Allergen allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
        _isNoneSelectedForAllergens = false;
      }
    });
  }

  void _clearAllRestrictions() {
    setState(() {
      _selectedRestrictions.clear();
      _isNoneSelectedForRestrictions = true;
    });
  }

  void _clearAllAllergens() {
    setState(() {
      _selectedAllergens.clear();
      _isNoneSelectedForAllergens = true;
    });
  }

  Future<void> _handleContinue() async {
    await _appStateService.setDietaryRestrictions(
      _selectedRestrictions.map((value) => value.name).toList(),
    );
    await _appStateService.setAllergens(
      _selectedAllergens.map((value) => value.name).toList(),
    );

    if (!mounted) return;
    context.push('/onboarding/step3');
  }

  void _handleBack() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      AppStrings.dietaryPreferencesTitle,
                      style: AppTextStyles.headline2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.dietaryPreferencesSubtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Dietary Restrictions
                    Text(
                      'Dietary Restrictions',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dietary Restriction Cards
                    ...DietaryRestriction.values.map((restriction) {
                      final isSelected = _selectedRestrictions.contains(restriction);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _DietaryRestrictionCard(
                          restriction: restriction,
                          isSelected: isSelected,
                          onTap: () => _toggleRestriction(restriction),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // None button
                    GestureDetector(
                      onTap: _clearAllRestrictions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isNoneSelectedForRestrictions
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary.withValues(alpha: 0.3),
                            width: _isNoneSelectedForRestrictions ? 2 : 1,
                          ),
                          boxShadow: _isNoneSelectedForRestrictions
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.none,
                              style: AppTextStyles.body.copyWith(
                                color: _isNoneSelectedForRestrictions
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (_isNoneSelectedForRestrictions)
                              const SizedBox(width: 8),
                            if (_isNoneSelectedForRestrictions)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Allergens
                    Text(
                      AppStrings.allergensTitle,
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.allergensSubtitle,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),

                    // Allergen Chips (horizontal wrap)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: Allergen.values.map((allergen) {
                        final isSelected = _selectedAllergens.contains(allergen);
                        return _AllergenChip(
                          allergen: allergen,
                          isSelected: isSelected,
                          onTap: () => _toggleAllergen(allergen),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    // None button for allergens
                    GestureDetector(
                      onTap: _clearAllAllergens,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isNoneSelectedForAllergens
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary.withValues(alpha: 0.3),
                            width: _isNoneSelectedForAllergens ? 2 : 1,
                          ),
                          boxShadow: _isNoneSelectedForAllergens
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.none,
                              style: AppTextStyles.body.copyWith(
                                color: _isNoneSelectedForAllergens
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (_isNoneSelectedForAllergens)
                              const SizedBox(width: 8),
                            if (_isNoneSelectedForAllergens)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: AppStrings.continueButton,
                onPressed: _handleContinue,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dietary restriction card widget
class _DietaryRestrictionCard extends StatelessWidget {
  final DietaryRestriction restriction;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietaryRestrictionCard({
    required this.restriction,
    required this.isSelected,
    required this.onTap,
  });

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
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: BaseCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: AppColors.cardBackground,
          borderRadius: 14,
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: restriction.iconBackgroundColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    restriction.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restriction.name,
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restriction.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.primaryGreen,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Allergen chip widget
class _AllergenChip extends StatelessWidget {
  final Allergen allergen;
  final bool isSelected;
  final VoidCallback onTap;

  const _AllergenChip({
    required this.allergen,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          allergen.name,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Dietary restriction enum
enum DietaryRestriction {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  lowCarbKeto,
  nutFree;

  String get name {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return AppStrings.vegetarian;
      case DietaryRestriction.vegan:
        return AppStrings.vegan;
      case DietaryRestriction.glutenFree:
        return AppStrings.glutenFree;
      case DietaryRestriction.dairyFree:
        return AppStrings.dairyFree;
      case DietaryRestriction.lowCarbKeto:
        return AppStrings.lowCarbKeto;
      case DietaryRestriction.nutFree:
        return AppStrings.nutFree;
    }
  }

  String get description {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return AppStrings.vegetarianDesc;
      case DietaryRestriction.vegan:
        return AppStrings.veganDesc;
      case DietaryRestriction.glutenFree:
        return AppStrings.glutenFreeDesc;
      case DietaryRestriction.dairyFree:
        return AppStrings.dairyFreeDesc;
      case DietaryRestriction.lowCarbKeto:
        return AppStrings.lowCarbKetoDesc;
      case DietaryRestriction.nutFree:
        return AppStrings.nutFreeDesc;
    }
  }

  String get emoji {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return '🥬';
      case DietaryRestriction.vegan:
        return '🌱';
      case DietaryRestriction.glutenFree:
        return '🌾';
      case DietaryRestriction.dairyFree:
        return '🥛';
      case DietaryRestriction.lowCarbKeto:
        return '🥑';
      case DietaryRestriction.nutFree:
        return '🥜';
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return const Color(0xFF4ADE80);
      case DietaryRestriction.vegan:
        return const Color(0xFF22C55E);
      case DietaryRestriction.glutenFree:
        return const Color(0xFFF59E0B);
      case DietaryRestriction.dairyFree:
        return const Color(0xFF3B82F6);
      case DietaryRestriction.lowCarbKeto:
        return const Color(0xFF8B5CF6);
      case DietaryRestriction.nutFree:
        return const Color(0xFFEF4444);
    }
  }
}

/// Allergen enum
enum Allergen {
  peanuts,
  treeNuts,
  dairy,
  shellfish,
  eggs,
  soy,
  wheat;

  String get name {
    switch (this) {
      case Allergen.peanuts:
        return AppStrings.peanuts;
      case Allergen.treeNuts:
        return AppStrings.treeNuts;
      case Allergen.dairy:
        return AppStrings.dairy;
      case Allergen.shellfish:
        return AppStrings.shellfish;
      case Allergen.eggs:
        return AppStrings.eggs;
      case Allergen.soy:
        return AppStrings.soy;
      case Allergen.wheat:
        return AppStrings.wheat;
    }
  }

  String get emoji {
    switch (this) {
      case Allergen.peanuts:
        return '🥜';
      case Allergen.treeNuts:
        return '🌰';
      case Allergen.dairy:
        return '🥛';
      case Allergen.shellfish:
        return '🦐';
      case Allergen.eggs:
        return '🥚';
      case Allergen.soy:
        return '🫘';
      case Allergen.wheat:
        return '🌾';
    }
  }
}
