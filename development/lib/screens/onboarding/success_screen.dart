import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';

/// Onboarding success screen - celebration screen
/// Mapped from mockup: 20-onboarding-success.png
class OnboardingSuccessScreen extends StatefulWidget {
  const OnboardingSuccessScreen({super.key});

  @override
  State<OnboardingSuccessScreen> createState() => _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState extends State<OnboardingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // User name will be fetched from User model once Firebase is integrated
  // For now, use a friendly default
  String get _userName => 'there'; // Will be replaced with actual user display name

  final int _wellnessScore = 82;

  final List<ConfettiParticle> _confettiParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Scale animation for checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade animation for content
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _scaleController.forward();
    _confettiController.forward();
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.5, // Start in upper half
        color: [
          AppColors.primaryGreen,
          AppColors.secondaryBlue,
          AppColors.accentAmber,
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFFEC4899), // Pink
        ][_random.nextInt(5)],
        size: 8.0 + _random.nextDouble() * 8.0,
        speed: 0.5 + _random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleGoToDashboard() {
    // Mark onboarding as complete (TODO: Save to Firebase)
    // User.onboardingCompleted = true;

    // Clear navigation stack and go to dashboard
    context.go('/dashboard');
  }

  void _handleBack() {
    context.pop();
  }

  String _getWelcomeMessage() {
    return AppStrings.youreAllSetUp.replaceAll('{name}', _userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 20,
              left: 20,
              child: Material(
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
            ),

            // Confetti background
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ConfettiPainter(
                    particles: _confettiParticles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success checkmark with scale animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 56,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Welcome message with fade animation
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            _getWelcomeMessage(),
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            AppStrings.holosReadyToHelp,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Wellness Score Preview Card
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: BaseCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  AppStrings.yourWellnessScore,
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 16),

                                // Small circular score preview
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background circle
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.success,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.success.withValues(alpha: 0.3),
                                              blurRadius: 16,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Progress indicator
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CircularProgressIndicator(
                                          value: _wellnessScore / 100.0,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Score text
                                      Text(
                                        '$_wellnessScore',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Great start! Keep it up 💪',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Go to Dashboard Button
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: PrimaryButton(
                            text: AppStrings.goToDashboard,
                            onPressed: _handleGoToDashboard,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confetti particle data class
class ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double speed;
  final double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
  })  : rotation = 0,
        rotationSpeed = (Math.random() * 2 - 1) * 0.2;
}

// Custom Math class for random
class Math {
  static double random() => Random().nextDouble();
}

/// Confetti painter for background animation
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    for (final particle in particles) {
      final paint = Paint()..color = particle.color.withValues(alpha: 1 - progress);

      // Calculate position with falling animation
      final x = particle.x * size.width;
      final y = particle.y * size.height + (progress * size.height * 0.8);

      // Wrap around if falls below screen
      final wrappedY = y % size.height;

      // Draw confetti (small circle)
      canvas.drawCircle(
        Offset(x, wrappedY),
        particle.size * (1 - progress * 0.5), // Shrink as it falls
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
