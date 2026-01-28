# Holos — Flutter Component Mapping Guide

**Purpose:** Maps 20 mockups to Flutter widgets and code snippets
**Location:** `holos/development/`
**Last Updated:** January 28, 2026

---

## 📋 Folder Structure

```
holos/
├── roadmap.md                          # Project roadmap
├── figma-tutorial.md                   # Figma design tutorial
├── assets/
│   └── mockup/                     # 20 visual mockups
│       ├── 01-dashboard.png
│       ├── ... (20 total)
│       └── README.md
└── development/                         # Flutter development
    ├── component-mapping.md            # THIS FILE
    ├── lib/                          # Flutter app code
    │   ├── main.dart                 # ✅ Entry point (TO CREATE)
    │   ├── config/
    │   │   ├── colors.dart            # ✅ Color constants
    │   │   ├── fonts.dart            # ✅ Typography
    │   │   └── strings.dart          # Text constants (TO CREATE)
    │   ├── models/                    # Data models
    │   │   ├── user.dart             # ✅ User model
    │   │   ├── food_entry.dart        # ✅ Food entry model
    │   │   ├── health_data.dart        # ✅ Health data model
    │   │   ├── wellness_score.dart    # ✅ Wellness score model
    │   │   ├── meal_plan.dart         # ✅ Meal plan model
    │   │   ├── notification_preference.dart  # ✅ Notification preferences
    │   │   └── recipe.dart           # Recipe model (TO CREATE)
    │   ├── screens/                   # Screen widgets
    │   │   ├── onboarding/
    │   │   │   ├── goal_selection.dart  # ✅ Goal selection screen
    │   │   │   ├── health_connection.dart # ✅ Health app connection
    │   │   │   ├── dietary_preferences.dart # ✅ Dietary preferences
    │   │   │   ├── success_screen.dart  # ✅ Success/celebration screen
    │   │   │   └── welcome_screen.dart
    │   │   ├── dashboard/
    │   │   │   └── dashboard_screen.dart  # ✅ Main dashboard screen
    │   │   ├── food_log/
    │   │   │   └── food_log_screen.dart  # ✅ Food tracking screen
    │   │   ├── health_data/
    │   │   │   └── health_data_screen.dart  # ✅ Health metrics screen
    │   │   └── ai_suggestion/
    │   │       └── ai_suggestion_screen.dart  # ✅ AI meal recommendations
    │   ├── notifications/
    │   │   └── notifications_screen.dart  # ✅ Proactive meal suggestions
    │   ├── meal_planner/
    │   │   └── meal_planner_screen.dart  # ✅ Weekly meal planning
    │   ├── widgets/                   # Reusable components
    │   │   ├── common/
    │   │   │   ├── base_card.dart         # ✅ Card widget
    │   │   │   ├── primary_button.dart    # ✅ Green action button
    │   │   │   ├── secondary_button.dart  # ✅ Blue action button
    │   │   │   ├── progress_bar.dart     # ✅ Progress bar widget
    │   │   │   ├── circular_score.dart    # ✅ Wellness score gauge
    │   │   │   └── text_widgets.dart    # Text widgets (TO CREATE)
    │   │   ├── dashboard/
    │   │   │   ├── snapshot_card.dart   # ✅ Snapshot metric card
    │   │   │   └── macro_card.dart     # ✅ Macro progress card
    │   │   ├── food_log/
    │   │   │   └── meal_card.dart      # ✅ Meal card widget
    │   │   ├── health_data/
    │   │   │   ├── health_metric_card.dart    # Health metric card (TO CREATE)
    │   │   │   └── sleep_quality_card.dart   # Sleep quality card (TO CREATE)
    │   │   └── ai_suggestion/
    │   │       └── meal_suggestion_card.dart   # ✅ AI meal card
    │   └── services/                 # API integrations
    │       ├── edamam_service.dart   # ✅ Edamam API
    │       ├── gemini_service.dart    # ✅ Gemini AI service
    │       ├── notification_service.dart  # ✅ Notification scheduling
    │       ├── health_service.dart     # Health platform sync (TO CREATE)
    │       └── firebase_service.dart  # Firebase integration (TO CREATE)
    ├── pubspec.yaml                    # ✅ Dependencies
    └── README.md                      # Flutter project docs (TO CREATE)
```
```

---

## 🎨 Color Palette

**Mapped from mockups → Flutter constants**

```dart
// lib/config/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF4ADE80);  // #4ADE80 - Main brand color
  static const Color secondaryBlue = Color(0xFF3B82F6); // #3B82F6 - Secondary actions
  static const Color accentAmber = Color(0xFFF59E0B);  // #F59E0B - Warning/alerts

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);      // #FFFFFF - Card backgrounds
  static const Color backgroundDark = Color(0xFF111827);   // #111827 - Dark mode
  static const Color textPrimary = Color(0xFF111827);   // #111827 - Headlines
  static const Color textSecondary = Color(0xFF6B7280); // #6B7280 - Captions

  // Status Colors
  static const Color success = Color(0xFF10B981);  // #10B981 - Good (80%+)
  static const Color warning = Color(0xFFF59E0B);  // #F59E0B - Warning (60-79%)
  static const Color error = Color(0xFFEF4444);    // #EF4444 - Poor (<60%)

  // Surface Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);     // 10% black
  static const Color progressBackground = Color(0xFFE5E7EB); // #E5E7EB
}
```

---

## 🎨 Typography

**Mapped from mockups → Flutter text styles**

```dart
// lib/config/fonts.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
```

---

## 📦 Common Widgets

### BaseCard
**Used in:** All screens — card component with shadow

```dart
// lib/widgets/common/base_card.dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const BaseCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
```

---

### PrimaryButton
**Used in:** All screens — main action button (green)

```dart
// lib/widgets/common/primary_button.dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width = 320,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimationColor<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
```

---

### SecondaryButton
**Used in:** Action buttons (blue)

```dart
// lib/widgets/common/secondary_button.dart
// Similar to PrimaryButton but with AppColors.secondaryBlue
class SecondaryButton extends StatelessWidget {
  // ... same as PrimaryButton
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryBlue,  // Different color!
          // ... rest same as PrimaryButton
        ),
        child: isLoading
            ? const CircularProgressIndicator(...)
            : Text(...),
      ),
    );
  }
}
```

---

### ProgressBar
**Used in:** Health metrics, macro progress

```dart
// lib/widgets/common/progress_bar.dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

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
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(height! / 2),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height! / 2),
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: progressColor),
            ),
          ),
        ],
      ),
      ],
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}
```

---

### CircularScore
**Used in:** Dashboard — wellness score gauge

```dart
// lib/widgets/common/circular_score.dart
import 'package:flutter/material.dart';
import '../config/colors.dart';

class CircularScore extends StatelessWidget {
  final int score; // 0 to 100
  final String? trend;
  final double size;

  const CircularScore({
    Key? key,
    required this.score,
    this.trend,
    this.size = 200,
  }) : super(key: key);

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
                color: color.withOpacity(0.2),
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
            valueColor: AlwaysStoppedAnimationColor<Color>(Colors.white),
          ),
        ),
        // Score number
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
```

---

## 📋 Screen Mappings (Mockup → Flutter)

### 01-dashboard.png → DashboardScreen

**Mockup Analysis:**
- Top: App bar with "Holos" + profile icon
- Hero: Large circular wellness score (82/100) with trend
- Middle: 4 metric cards (Sleep, Nutrition, Activity, Stress)
- Bottom: 3 macro cards (Protein, Carbs, Fat)
- Actions: "Log Food" (green), "AI Suggestion" (blue)

**Flutter Structure:**
```dart
// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/circular_score.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/dashboard/snapshot_card.dart';
import '../../widgets/dashboard/macro_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Holos'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.secondaryBlue,
            child: const Text('E'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Wellness Score Hero
            CircularScore(
              score: 82,
              trend: '↑ 5 points this week',
            ),
            const SizedBox(height: 20),

            // Today's Snapshot
            const Text(
              "Today's Snapshot",
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            BaseCard(
              child: Column(
                children: const [
                  SnapshotCard(label: 'Sleep', value: '7h', progress: 0.9),
                  SnapshotCard(label: 'Nutrition', value: '60%', progress: 0.6),
                  SnapshotCard(label: 'Activity', value: '8.5k', progress: 0.85),
                  SnapshotCard(label: 'Stress', value: '72', progress: 0.72),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Macros Progress
            const Text(
              "Macros Progress",
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: MacroCard(label: 'Protein', current: '90g', target: '150g')),
                Expanded(child: MacroCard(label: 'Carbs', current: '120g', target: '200g')),
                Expanded(child: MacroCard(label: 'Fat', current: '45g', target: '70g')),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: '+ Log Food',
                    onPressed: () => Navigator.pushNamed(context, '/food-log'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SecondaryButton(
                    text: 'AI Suggestion',
                    onPressed: () => Navigator.pushNamed(context, '/ai-suggestion'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 02-nutrition-insights.png → FoodLogScreen

**Mockup Analysis:**
- Top: Back arrow + "Today's Log 2/5 items" (amber)
- Meals: Breakfast (8:30 AM), Lunch (12:30 PM) cards
- Actions: Barcode scan button (large, green), search bar, quick add
- Bottom: Daily totals (1000/2000 kcal + macros)

**Flutter Structure:**
```dart
// lib/screens/food_log/food_log_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/food_log/meal_card.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Today's Log"),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '2/5 items',
              style: AppTextStyles.label.copyWith(color: AppColors.accentAmber),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Breakfast
          const Text('Breakfast', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          MealCard(
            emoji: '🍳',
            name: 'Overnight oats',
            macros: '450 kcal | P:15g C:60g F:8g',
            time: '8:30 AM',
          ),
          const SizedBox(height: 16),

          // Lunch
          const Text('Lunch', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          MealCard(
            emoji: '🥗',
            name: 'Grilled chicken salad',
            macros: '550 kcal | P:45g C:20g F:25g',
            time: '12:30 PM',
          ),
          const SizedBox(height: 24),

          // Barcode Scan
          PrimaryButton(
            text: '📷 Barcode Scan',
            onPressed: () => _scanBarcode(context),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search Food...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: SecondaryButton(text: '+ Quick Add'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SecondaryButton(text: 'Add Recipe'),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 16),

          // Daily Total
          BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s Total', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                const Text(
                  '1000/2000 kcal',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('P:60g C:80g F:33g', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scanBarcode(BuildContext context) {
    // Barcode scanning logic
  }
}
```

---

### 07-onboarding-goal.png → GoalSelectionScreen

**Mockup Analysis:**
- Top: "What's your main goal?"
- Content: 6 goal cards in vertical list
- Bottom: Green "Continue →" button
- Cards: Weight Loss, Build Muscle, Maintain, Reduce Stress, Improve Sleep, Get Active

**Flutter Structure:**
```dart
// lib/screens/onboarding/goal_selection_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  final List<GoalOption> goals = const [
    GoalOption(
      emoji: '🎯',
      title: 'Weight Loss',
      description: 'Lose 1 kg/week',
    ),
    GoalOption(
      emoji: '💪',
      title: 'Build Muscle',
      description: 'Gain muscle & strength',
    ),
    GoalOption(
      emoji: '⚖️',
      title: 'Maintain Weight',
      description: 'Stay at current weight',
    ),
    GoalOption(
      emoji: '😌',
      title: 'Reduce Stress',
      description: 'Lower stress levels',
    ),
    GoalOption(
      emoji: '😴',
      title: 'Improve Sleep',
      description: 'Better sleep quality',
    ),
    GoalOption(
      emoji: '🏃',
      title: 'Get More Active',
      description: 'Increase daily activity',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                "What's your main goal?",
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BaseCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  goals[index].emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    goals[index].title,
                                    style: AppTextStyles.headline3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              goals[index].description,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              PrimaryButton(
                text: 'Continue →',
                onPressed: () => Navigator.pushNamed(context, '/onboarding/step1'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalOption {
  final String emoji;
  final String title;
  final String description;

  const GoalOption({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
```

---

### 04-recipe-card.png → AiSuggestionScreen

**Mockup Analysis:**
- Top: "🍽️ Time for dinner!" with context message
- Hero: Large meal card with food image
- Meal: "Salmon Bowl" + macros (700 kcal, P:40g C:35g F:30g)
- Description: "Grilled salmon with quinoa, roasted veggies..."
- Actions: "Add to Log" (green), "View Recipe" (blue)

**Flutter Structure:**
```dart
// lib/screens/ai_suggestion/ai_suggestion_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/ai_suggestion/meal_suggestion_card.dart';

class AiSuggestionScreen extends StatelessWidget {
  const AiSuggestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Text('🍽️', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Text(
                    'Time for dinner!',
                    style: AppTextStyles.headline3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: const Text(
                  'Great day, Ernest! You burned 800 calories. Here\'s a recovery meal:',
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 24),

              // Meal Card
              MealSuggestionCard(
                image: 'assets/images/salmon_bowl.png',
                name: '🍲 Salmon Bowl',
                macros: '700 kcal | P:40g C:35g F:30g',
                description: 'Grilled salmon with quinoa, roasted veggies, and lemon-herb dressing',
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Add to Log',
                      onPressed: () => _addToLog(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SecondaryButton(
                      text: 'View Recipe',
                      onPressed: () => _viewRecipe(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToLog(BuildContext context) {
    // Add meal to log logic
  }

  void _viewRecipe(BuildContext context) {
    // Show full recipe logic
  }
}
```

---

## 📋 Additional Widget Code

### SnapshotCard (Dashboard)
```dart
// lib/widgets/dashboard/snapshot_card.dart
import 'package:flutter/material.dart';
import '../common/progress_bar.dart';

class SnapshotCard extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const SnapshotCard({
    Key? key,
    required this.label,
    required this.value,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: ProgressBar(value: progress, width: 200)),
          SizedBox(
            width: 50,
            child: Text(value, style: AppTextStyles.headline3),
          ),
        ],
      ),
    );
  }
}
```

### MacroCard (Dashboard)
```dart
// lib/widgets/dashboard/macro_card.dart
import 'package:flutter/material.dart';
import '../common/progress_bar.dart';

class MacroCard extends StatelessWidget {
  final String label;
  final String current;
  final String target;
  final double progress;

  const MacroCard({
    Key? key,
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(
            '$current/$target',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ProgressBar(value: progress, width: 75, height: 6),
        ],
      ),
    );
  }
}
```

### MealCard (Food Log)
```dart
// lib/widgets/food_log/meal_card.dart
import 'package:flutter/material.dart';
import '../common/base_card.dart';

class MealCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String macros;
  final String time;

  const MealCard({
    Key? key,
    required this.emoji,
    required this.name,
    required this.macros,
    required this.time,
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
                Text(name, style: AppTextStyles.headline3),
                const SizedBox(height: 4),
                Text(macros, style: AppTextStyles.caption),
              ],
            ),
          ),
          Checkbox(value: false, onChanged: (v) {}),
        ],
      ),
    );
  }
}
```

### MealSuggestionCard (AI Suggestion)
```dart
// lib/widgets/ai_suggestion/meal_suggestion_card.dart
import 'package:flutter/material.dart';
import '../common/base_card.dart';

class MealSuggestionCard extends StatelessWidget {
  final String image;
  final String name;
  final String macros;
  final String description;

  const MealSuggestionCard({
    Key? key,
    required this.image,
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
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text('[Food Image]', style: AppTextStyles.caption),
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
```

---

## 📱 Quick Reference Table

| Mockup | Screen | Key Widgets | File Location |
|---------|--------|--------------|----------------|
| 01-dashboard.png | Dashboard | CircularScore, SnapshotCard, MacroCard, PrimaryButton, SecondaryButton | `lib/screens/dashboard/dashboard_screen.dart` ✅ |
| 02-nutrition-insights.png | Food Log | MealCard, BaseCard, TextField, PrimaryButton, SecondaryButton | `lib/screens/food_log/food_log_screen.dart` ✅ |
| 03-health-insights.png | Health Data | DetailedHealthMetricCard, PrimaryButton, ProgressBar | `lib/screens/health_data/health_data_screen.dart` ✅ |
| 04-recipe-card.png | AI Suggestion | MealSuggestionCard, PrimaryButton, SecondaryButton | `lib/screens/ai_suggestion/ai_suggestion_screen.dart` ✅ |
| 07-onboarding-goal.png | Goal Selection | BaseCard, PrimaryButton, ListView | `lib/screens/onboarding/goal_selection.dart` |
| 16-onboarding-step1.png | Health Connection | BaseCard, PrimaryButton, SecondaryButton, Icon, Checkbox | `lib/screens/onboarding/health_connection.dart` |
| 17-onboarding-step2.png | Dietary Preferences | BaseCard, PrimaryButton, Checkbox, Chip | `lib/screens/onboarding/dietary_preferences.dart` |
| 20-onboarding-success.png | Success Screen | BaseCard, PrimaryButton, Animation, Circular Score | `lib/screens/onboarding/success_screen.dart` |
| 10-dashboard-alt.png | Alt Dashboard | Alternative layout widgets | `lib/screens/dashboard/` |
| 11-profile-settings.png | Settings | Switch, ListTile, BaseCard | `lib/screens/settings/` |
| 12-notifications.png | Notifications | Card, Text, Icon, Time | `lib/screens/notifications/notifications_screen.dart` ✅ |
| 13-meal-schedule.png | Meal Planner | CalendarCard, MealCard, TimePicker | `lib/screens/meal_planner/meal_planner_screen.dart` ✅ |
| 14-activity-details.png | Activity Details | Chart, ListView, Text | `lib/screens/health_data/` |
| 15-splash-screen.png | Splash | Image, Text, Progress | `lib/screens/splash.dart` |

---

## 🚀 Development Workflow

### 1. Before Coding
1. **Open mockup** folder
2. **Study the screen** you're building
3. **Identify widgets** from this guide
4. **Copy code snippets** as starting point

### 2. While Coding
1. **Keep mockup image open** on second monitor
2. **Reference spacing** from mockup
3. **Match colors** using AppColors constants
4. **Use pre-built widgets** (BaseCard, PrimaryButton, etc.)

### 3. After Coding
1. **Compare with mockup**
2. **Adjust spacing/sizing** if needed
3. **Test on both iOS and Android**
4. **Iterate based on testing**

---

## 📚 Dependencies (pubspec.yaml)

```yaml
# Add to pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.6

  # Health Integrations
  health: ^10.1.0
  samsung_health: ^0.0.1

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0

  # State Management
  flutter_riverpod: ^2.5.0

  # HTTP/API
  http: ^1.2.0
  cached_network_image: ^3.3.0

  # Navigation
  go_router: ^13.0.0

  # Charts (Phase 2)
  fl_chart: ^0.66.0

  # Icons
  cupertino_icons: ^1.0.6
```

---

## 💡 Tips for Efficient Coding

1. **Use common widgets first** — Build BaseCard, PrimaryButton before screens
2. **Extract constants** — All colors/text in one place
3. **Reference mockups constantly** — Keep image open while coding
4. **Start with MVP screens** — Dashboard, Food Log, Onboarding first
5. **Test on real devices** — iOS and Android
6. **Iterate quickly** — Don't overthink, ship MVP

---

**Questions?** This guide maps all 20 mockups to Flutter widgets. Use it as your coding companion! 🚀
