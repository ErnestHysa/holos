import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import '../../config/colors.dart';
import '../../config/fonts.dart';
import '../../config/strings.dart';
import '../../widgets/common/base_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Health connection screen for onboarding step 1
/// Mapped from mockup: 16-onboarding-step1.png
class HealthConnectionScreen extends StatefulWidget {
  const HealthConnectionScreen({super.key});

  @override
  State<HealthConnectionScreen> createState() => _HealthConnectionScreenState();
}

class _HealthConnectionScreenState extends State<HealthConnectionScreen> {
  // Platform connection states
  final Map<HealthPlatform, ConnectionState> _connectionStates = {
    HealthPlatform.appleHealth: ConnectionState.disconnected,
    HealthPlatform.googleFit: ConnectionState.disconnected,
    HealthPlatform.samsungHealth: ConnectionState.disconnected,
  };

  // Privacy sync options - all default to true
  bool _syncWorkouts = true;
  bool _syncSleep = true;
  bool _syncHeartRate = true;
  bool _syncStress = true;

  // Health factory for accessing the health package
  final Health _health = Health();

  // List of health data types to request (using only basic supported types)
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // Permissions - matching length of types (all READ)
  static final List<HealthDataAccess> _permissions = List.generate(
    4,
    (_) => HealthDataAccess.READ,
  );

  Future<void> _connectPlatform(HealthPlatform platform) async {
    if (_connectionStates[platform] != ConnectionState.disconnected) return;

    setState(() {
      _connectionStates[platform] = ConnectionState.connecting;
    });

    try {
      // First check if permissions are already granted
      final bool hasPermissions = await _health.hasPermissions(
        _dataTypes,
        permissions: _permissions,
      ) ??
          false;

      if (!mounted) return;

      if (hasPermissions) {
        // Already has permissions - mark as connected
        setState(() {
          _connectionStates[platform] = ConnectionState.connected;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${platform.name} connected successfully!'),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Request permissions - this will open Health Connect on Android
      final bool granted = (await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      ).catchError((error) {
        debugPrint('Health authorization error: $error');
        // Show Health Connect setup dialog
        if (mounted) {
          _showHealthConnectDialog();
        }
        return false;
<<<<<<< HEAD
      }));
=======
      })) ??
          false;

      if (!mounted) return;
>>>>>>> 98a8bb278a9e1a0ebde90c77b8804772a13d699f

      if (granted) {
        // Connection successful
        setState(() {
          _connectionStates[platform] = ConnectionState.connected;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${platform.name} connected successfully!'),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Permission denied or cancelled
        setState(() {
          _connectionStates[platform] = ConnectionState.disconnected;
        });

        if (mounted) {
          _showHealthConnectDialog();
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Error during connection
      setState(() {
        _connectionStates[platform] = ConnectionState.disconnected;
      });

      debugPrint('Connection error: $e');

      if (mounted) {
        _showHealthConnectDialog();
      }
    }
  }

  void _showHealthConnectDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Connect Required'),
        content: const Text(
          'To read health data from Samsung Health on your Android 16 device, you need Health Connect:\n\n'
          '1. Install "Health Connect" from the Play Store\n'
          '2. Open Health Connect and connect Samsung Health\n'
          '3. Return here and tap Connect again\n\n'
          'Health Connect is the official way to access health data on modern Android.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Instructions shown - user can open Play Store manually
            },
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    context.push('/onboarding/step2');
  }

  void _handleSkip() {
    context.push('/dashboard');
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
                AppStrings.connectHealthData,
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.connectHealthDataSubtitle,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Platform Cards
              Text(
                'Select a platform',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _PlatformCard(
                      platform: HealthPlatform.appleHealth,
                      state: _connectionStates[HealthPlatform.appleHealth]!,
                      onConnect: () => _connectPlatform(HealthPlatform.appleHealth),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlatformCard(
                      platform: HealthPlatform.googleFit,
                      state: _connectionStates[HealthPlatform.googleFit]!,
                      onConnect: () => _connectPlatform(HealthPlatform.googleFit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlatformCard(
                      platform: HealthPlatform.samsungHealth,
                      state: _connectionStates[HealthPlatform.samsungHealth]!,
                      onConnect: () => _connectPlatform(HealthPlatform.samsungHealth),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Privacy Options
              Text(
                'Privacy controls',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              BaseCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _PrivacyCheckbox(
                      label: AppStrings.syncWorkouts,
                      value: _syncWorkouts,
                      onChanged: (value) => setState(() => _syncWorkouts = value ?? true),
                    ),
                    const SizedBox(height: 12),
                    _PrivacyCheckbox(
                      label: AppStrings.syncSleepData,
                      value: _syncSleep,
                      onChanged: (value) => setState(() => _syncSleep = value ?? true),
                    ),
                    const SizedBox(height: 12),
                    _PrivacyCheckbox(
                      label: AppStrings.syncHeartRate,
                      value: _syncHeartRate,
                      onChanged: (value) => setState(() => _syncHeartRate = value ?? true),
                    ),
                    const SizedBox(height: 12),
                    _PrivacyCheckbox(
                      label: AppStrings.syncStressData,
                      value: _syncStress,
                      onChanged: (value) => setState(() => _syncStress = value ?? true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              PrimaryButton(
                text: AppStrings.continueButton,
                onPressed: _handleContinue,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: AppStrings.skip,
                onPressed: _handleSkip,
                width: double.infinity,
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

/// Platform card widget with connection state
class _PlatformCard extends StatelessWidget {
  final HealthPlatform platform;
  final ConnectionState state;
  final VoidCallback onConnect;

  const _PlatformCard({
    required this.platform,
    required this.state,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == ConnectionState.connected;
    final isConnecting = state == ConnectionState.connecting;

    return GestureDetector(
      onTap: isConnecting ? null : onConnect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected ? AppColors.primaryGreen : Colors.transparent,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          backgroundColor: AppColors.cardBackground,
          borderRadius: 14,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Platform Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: platform.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    platform.icon,
                    color: platform.iconColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Platform Name
              Text(
                platform.name,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Connection Status
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryGreen,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.connected,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isConnecting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppStrings.connect,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Privacy checkbox widget
class _PrivacyCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _PrivacyCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

/// Health platform enum
enum HealthPlatform {
  appleHealth,
  googleFit,
  samsungHealth;

  String get name {
    switch (this) {
      case HealthPlatform.appleHealth:
        return AppStrings.appleHealth;
      case HealthPlatform.googleFit:
        return AppStrings.googleFit;
      case HealthPlatform.samsungHealth:
        return AppStrings.samsungHealth;
    }
  }

  IconData get icon {
    switch (this) {
      case HealthPlatform.appleHealth:
        return Icons.favorite;
      case HealthPlatform.googleFit:
        return Icons.fitness_center;
      case HealthPlatform.samsungHealth:
        return Icons.watch;
    }
  }

  Color get iconColor {
    switch (this) {
      case HealthPlatform.appleHealth:
        return const Color(0xFF000000);
      case HealthPlatform.googleFit:
        return const Color(0xFF4285F4);
      case HealthPlatform.samsungHealth:
        return const Color(0xFF1428A0);
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case HealthPlatform.appleHealth:
        return const Color(0xFFF5F5F5);
      case HealthPlatform.googleFit:
        return const Color(0xFFE8F0FE);
      case HealthPlatform.samsungHealth:
        return const Color(0xFFE8EDF5);
    }
  }
}

/// Connection state enum
enum ConnectionState {
  disconnected,
  connecting,
  connected,
}
