import 'package:flutter/material.dart';

/// Institutional color palette — professional blue/teal theme.
/// Easily swappable once brand guidelines arrive.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF1240A8);
  static const Color primaryLight = Color(0xFF3B82F6);

  // ── Accent / Secondary ──
  static const Color accent = Color(0xFF0EA5E9);
  static const Color accentLight = Color(0xFF7DD3FC);
  static const Color secondary = accent;

  // ── Backgrounds ──
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sidebarBg = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // ── Borders ──
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ── Semantic ──
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Status chips ──
  static const Color draft = Color(0xFF94A3B8);
  static const Color pending = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF16A34A);
  static const Color rejected = Color(0xFFDC2626);
  static const Color awarded = Color(0xFF7C3AED);

  // ── Lowest price highlight ──
  static const Color lowestPriceBg = Color(0xFFDCFCE7);
  static const Color lowestPriceBorder = Color(0xFF16A34A);
}
