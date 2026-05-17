import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFF1A1A2E);
  static const accent = Color(0xFF4F46E5);
  static const accentLight = Color(0xFF6366F1);
  static const background = Color(0xFFF8F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const inputFill = Color(0xFFF9FAFB);
}

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const full = 100.0;
}
