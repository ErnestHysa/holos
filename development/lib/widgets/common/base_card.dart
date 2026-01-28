import 'package:flutter/material.dart';
import '../../config/colors.dart';

/// Base card widget used across all screens
/// Mapped from mockup: White card with shadow
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? backgroundColor;

  const BaseCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
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
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
