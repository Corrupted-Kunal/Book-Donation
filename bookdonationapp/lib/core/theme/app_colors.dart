import 'package:flutter/material.dart';

/// Design system colors for Book Donation App
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color amber = Color(0xFFFFA000);
  static const Color destructiveRed = Color(0xFFE53935);

  // Background Colors
  static const Color background = Color(0xFFFAFBFC);
  static const Color mutedBg = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF8FAFC);

  // Border
  static const Color border = Color.fromRGBO(15, 23, 42, 0.08);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF64748B);

  // Status Colors
  static const Color statusCompleted = accentGreen;
  static const Color statusPending = amber;
  static const Color statusInTransit = secondaryBlue;
  static const Color statusConfirmed = secondaryBlue;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, secondaryBlue],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, Color(0xFFFFB300)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, Color(0xFF66BB6A)],
  );
}

/// Design system shadows
class AppShadows {
  static List<BoxShadow> get sharpBase => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get sharpLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get sharpXL => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: AppColors.accentGreen.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
}

/// Border radius constants
class AppRadius {
  static const double headerBottom = 32.0;
  static const double statCard = 32.0;
  static const double normalCard = 16.0;
  static const double button = 12.0;
  static const double badge = 9999.0; // Pill shape
}
