import 'package:flutter/material.dart';

/// App color palette mapped from mockup assets
/// Based on Holos design system
class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF4ADE80);  // #4ADE80 - Main brand color
  static const Color secondaryBlue = Color(0xFF3B82F6); // #3B82F6 - Secondary actions

  // Accent Colors
  static const Color accentAmber = Color(0xFFF59E0B);  // #F59E0B - Warning/alerts

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);      // #F5F5F5 - App background
  static const Color cardBackground = Color(0xFFFFFFFF);  // #FFFFFF - Card backgrounds
  static const Color backgroundDark = Color(0xFF111827);  // #111827 - Dark mode
  static const Color textPrimary = Color(0xFF111827);   // #111827 - Headlines
  static const Color textSecondary = Color(0xFF6B7280); // #6B7280 - Captions

  // Status Colors
  static const Color success = Color(0xFF10B981);  // #10B981 - Good (80%+)
  static const Color warning = Color(0xFFF59E0B);  // #F59E0B - Warning (60-79%)
  static const Color error = Color(0xFFEF4444);    // #EF4444 - Poor (<60%)

  // Surface Colors
  static const Color cardShadow = Color(0x1A000000);     // 10% black
  static const Color progressBackground = Color(0xFFE5E7EB); // #E5E7EB

  // Input Colors
  static const Color inputBackground = Color(0xFFF3F4F6);
  static const Color inputBorder = Color(0xFFE5E7EB);
}
