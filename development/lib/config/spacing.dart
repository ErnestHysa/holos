import 'package:flutter/material.dart';

/// Consistent spacing values for the Holos app
///
/// Usage:
/// ```dart
/// SizedBox(height: AppSpacing.sm)
/// EdgeInsets.all(AppSpacing.md)
/// ```
///
/// Spacing scale (4px base unit):
/// - xs: 4px (smallest gap)
/// - sm: 8px (small gap, icon padding)
/// - md: 12px (medium gap, card inner padding)
/// - lg: 16px (large gap, standard padding)
/// - xl: 24px (extra large gap, section spacing)
/// - xxl: 32px (2x large gap, major section spacing)
/// - xxxl: 48px (3x large gap, screen edges)

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Edge insets helpers
  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  // Horizontal insets
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical insets
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // Screen padding (standard)
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // Input padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}
