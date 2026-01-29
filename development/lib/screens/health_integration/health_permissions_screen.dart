import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS-style icons
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/spacing.dart';
import '../../config/strings.dart';
import '../../services/health_service.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Health Permissions Screen - Request health app access
/// Extension of onboarding flow for connecting health platforms
class HealthPermissionsScreen extends StatefulWidget {
  const HealthPermissionsScreen({Key? key}) : super(key: key);

  @override
  State<HealthPermissionsScreen> createState() =>
      _HealthPermissionsScreenState();
}

class _HealthPermissionsScreenState extends State<HealthPermissionsScreen> {
  final HealthService _healthService = HealthService();

  // Platform connection states
  bool _isAppleHealthEnabled = true;
  bool _isGoogleFitEnabled = true;
  bool _isSamsungHealthEnabled = true;

  // Connection status
  bool _isAppleHealthConnected = false;
  bool _isGoogleFitConnected = false;
  bool _isSamsungHealthConnected = false;

  // Loading states
  Set<HealthPlatform> _connectingPlatforms = {};

  // Supported platforms
  Set<HealthPlatform> _supportedPlatforms = {};

  @override
  void initState() {
    super.initState();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    await _healthService.initialize();
    if (!mounted) return;

    setState(() {
      _supportedPlatforms = Set.of(_healthService.supportedPlatforms);

      // Disable unsupported platforms
      _isAppleHealthEnabled =
          _supportedPlatforms.contains(HealthPlatform.appleHealth);
      _isGoogleFitEnabled =
          _supportedPlatforms.contains(HealthPlatform.googleFit);
      _isSamsungHealthEnabled =
          _supportedPlatforms.contains(HealthPlatform.samsungHealth);
    });

    // Check existing permissions
    for (final platform in _supportedPlatforms) {
      final hasPermission = await _healthService.hasPermission(platform);
      if (!mounted) return;

      setState(() {
        switch (platform) {
          case HealthPlatform.appleHealth:
            _isAppleHealthConnected = hasPermission;
            break;
          case HealthPlatform.googleFit:
            _isGoogleFitConnected = hasPermission;
            break;
          case HealthPlatform.samsungHealth:
            _isSamsungHealthConnected = hasPermission;
            break;
        }
      });
    }
  }

  Future<void> _connectPlatform(HealthPlatform platform) async {
    setState(() {
      _connectingPlatforms.add(platform);
    });

    final granted = await _healthService.requestPermission(context, platform);
    if (!mounted) return;

    setState(() {
      _connectingPlatforms.remove(platform);
      switch (platform) {
        case HealthPlatform.appleHealth:
          _isAppleHealthConnected = granted;
          break;
        case HealthPlatform.googleFit:
          _isGoogleFitConnected = granted;
          break;
        case HealthPlatform.samsungHealth:
          _isSamsungHealthConnected = granted;
          break;
      }
    });

    if (granted) {
      _showSuccessSnackBar(platform);
    } else {
      _showErrorSnackBar(platform);
    }
  }

  void _showSuccessSnackBar(HealthPlatform platform) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${HealthService.getPlatformDisplayName(platform)} connected successfully!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(HealthPlatform platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Could not connect to ${HealthService.getPlatformDisplayName(platform)}'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContinue() {
    // Navigate to health data screen
    context.push('/health-data');
  }

  void _handleSkip() {
    // Allow user to skip and go to dashboard
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),

              // Explanation text
              _buildExplanation(),
              const SizedBox(height: AppSpacing.xl),

              // Platform selection section
              _buildPlatformSection(),
              const SizedBox(height: AppSpacing.xl),

              // Platform cards
              if (_isAppleHealthEnabled ||
                  _isGoogleFitEnabled ||
                  _isSamsungHealthEnabled)
                _buildPlatformCards(),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              _buildActionButtons(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity( 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.favorite_outline,
              size: 32,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          'Connect your health data',
          style: AppTextStyles.headline1,
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Why connect?',
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'We\'ll pull your steps, workouts, sleep, heart rate, and stress levels to give you a complete wellness picture.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '• Personalized meal suggestions based on your activity\n'
            '• Accurate wellness scores using real data\n'
            '• Smart notifications triggered by your health patterns',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select which health apps to connect:',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'All platforms are enabled by default. Toggle to disable.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCards() {
    return Column(
      children: [
        // Apple Health Card (iOS only)
        if (_isAppleHealthEnabled)
          _PlatformToggleCard(
            name: 'Apple Health',
            description: 'Connect to your iPhone\'s health data',
            icon: _buildAppleIcon(),
            isEnabled: _isAppleHealthEnabled,
            isConnected: _isAppleHealthConnected,
            isConnecting:
                _connectingPlatforms.contains(HealthPlatform.appleHealth),
            onToggle: (enabled) {
              setState(() => _isAppleHealthEnabled = enabled);
            },
            onConnect: () => _connectPlatform(HealthPlatform.appleHealth),
          ),
        if (_isAppleHealthEnabled) const SizedBox(height: AppSpacing.md),

        // Google Fit Card (Android only)
        if (_isGoogleFitEnabled)
          _PlatformToggleCard(
            name: 'Google Fit',
            description: 'Connect to your Google health data',
            icon: _buildGoogleFitIcon(),
            isEnabled: _isGoogleFitEnabled,
            isConnected: _isGoogleFitConnected,
            isConnecting:
                _connectingPlatforms.contains(HealthPlatform.googleFit),
            onToggle: (enabled) {
              setState(() => _isGoogleFitEnabled = enabled);
            },
            onConnect: () => _connectPlatform(HealthPlatform.googleFit),
          ),
        if (_isGoogleFitEnabled) const SizedBox(height: AppSpacing.md),

        // Samsung Health Card (Android only)
        if (_isSamsungHealthEnabled)
          _PlatformToggleCard(
            name: 'Samsung Health',
            description: 'Connect to your Samsung health data',
            icon: _buildSamsungIcon(),
            isEnabled: _isSamsungHealthEnabled,
            isConnected: _isSamsungHealthConnected,
            isConnecting:
                _connectingPlatforms.contains(HealthPlatform.samsungHealth),
            onToggle: (enabled) {
              setState(() => _isSamsungHealthEnabled = enabled);
            },
            onConnect: () => _connectPlatform(HealthPlatform.samsungHealth),
          ),
      ],
    );
  }

  Widget _buildAppleIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.apple,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildGoogleFitIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity( 0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          color: AppColors.primaryGreen,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSamsungIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity( 0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.watch,
          color: Colors.blue,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final anyConnected = _isAppleHealthConnected ||
        _isGoogleFitConnected ||
        _isSamsungHealthConnected;

    return Column(
      children: [
        // Continue button
        PrimaryButton(
          text: anyConnected ? 'Continue' : 'Skip for now',
          onPressed: _handleContinue,
          width: double.infinity,
        ),
        const SizedBox(height: AppSpacing.md),

        // Skip link
        if (!anyConnected)
          GestureDetector(
            onTap: _handleSkip,
            child: Text(
              'Go to Dashboard',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}

/// Platform toggle card widget
class _PlatformToggleCard extends StatefulWidget {
  final String name;
  final String description;
  final Widget icon;
  final bool isEnabled;
  final bool isConnected;
  final bool isConnecting;
  final ValueChanged<bool> onToggle;
  final VoidCallback onConnect;

  const _PlatformToggleCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.isEnabled,
    required this.isConnected,
    required this.isConnecting,
    required this.onToggle,
    required this.onConnect,
  });

  @override
  State<_PlatformToggleCard> createState() => _PlatformToggleCardState();
}

class _PlatformToggleCardState extends State<_PlatformToggleCard> {
  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: widget.isEnabled ? null : AppColors.inputBackground,
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              widget.icon,
              const SizedBox(width: AppSpacing.md),

              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTextStyles.headline3.copyWith(
                        fontSize: 16,
                        color: widget.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status indicator
              if (widget.isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity( 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Connected',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )
              else if (widget.isConnecting)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                )
              else
                // Connect button
                GestureDetector(
                  onTap: widget.isEnabled ? widget.onConnect : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isEnabled
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Connect',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
