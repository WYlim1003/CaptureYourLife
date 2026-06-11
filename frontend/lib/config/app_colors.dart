import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A43CC);

  static const Color secondaryColor = Color(0xFFFF6584);
  static const Color accentColor = Color(0xFF43E97B);

  // Dark theme backgrounds
  static const Color backgroundColor = Color(0xFF0F0F1A);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);
  static const Color overlayColor = Color(0xFF0D1117);

  // Error
  static const Color errorColor = Color(0xFFFF4757);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFAAAAAF);
  static const Color textTertiary = Color(0xFF666680);

  // Borders & dividers
  static const Color borderColor = Color(0xFF2A2A4A);
  static const Color dividerColor = Color(0xFF1E1E35);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF9D50BB)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );
}
