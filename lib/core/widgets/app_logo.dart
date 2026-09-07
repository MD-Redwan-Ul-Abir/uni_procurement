import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centralized branded logo for UniProcure.
/// Renders the custom university e-procurement shield/pillar emblem.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final TextStyle? textStyle;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 32,
    this.showText = false,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.16),
        child: Image.asset(
          'assets/images/uniprocure_icon.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.account_balance,
            color: AppColors.primary,
            size: size * 0.7,
          ),
        ),
      ),
    );

    if (!showText) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.35),
        Text(
          'UniProcure',
          style: textStyle ??
              TextStyle(
                color: textColor ?? AppColors.primary,
                fontSize: size * 0.62,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}
