import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'config/colors.dart';
import 'config/fonts.dart';
import 'config/strings.dart';
import 'screens/onboarding/goal_selection.dart';
import 'screens/onboarding/health_connection.dart';
import 'screens/onboarding/dietary_preferences.dart';
import 'screens/onboarding/success_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/food_log/food_log_screen.dart';
import 'screens/health_data/health_data_screen.dart';
import 'screens/ai_suggestion/ai_suggestion_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/meal_planner/meal_planner_screen.dart';
import 'screens/health_integration/health_permissions_screen.dart';

/// Holos App Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional for testing)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured - continue without it
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const HolosApp());
}

class HolosApp extends StatelessWidget {
  const HolosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headline3,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTextStyles.headline1,
          headlineMedium: AppTextStyles.headline2,
          titleMedium: AppTextStyles.headline3,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
          labelMedium: AppTextStyles.label,
        ),
      ),
      routerConfig: GoRouter(
        initialLocation: '/onboarding/goal',
        routes: [
          // Onboarding Routes
          GoRoute(
            path: '/onboarding/goal',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const GoalSelectionScreen(),
            ),
          ),
          GoRoute(
            path: '/onboarding/step1',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const HealthConnectionScreen(),
            ),
          ),
          GoRoute(
            path: '/onboarding/step2',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const DietaryPreferencesScreen(),
            ),
          ),
          GoRoute(
            path: '/onboarding/step3',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const OnboardingSuccessScreen(),
            ),
          ),
          // Main App Routes
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/food-log',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const FoodLogScreen(),
            ),
          ),
          GoRoute(
            path: '/health-data',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const HealthDataScreen(),
            ),
          ),
          GoRoute(
            path: '/health-permissions',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const HealthPermissionsScreen(),
            ),
          ),
          GoRoute(
            path: '/ai-suggestion',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const AiSuggestionScreen(),
            ),
          ),
          // Phase 2 Routes
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/meal-planner',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const MealPlannerScreen(),
            ),
          ),
          // Additional routes (to be added later)
          // '/settings',
        ],
        errorBuilder: (context, state) => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder screens - To be implemented using mockup mapping
// All core MVP screens are now complete!
