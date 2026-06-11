import 'package:flutter/material.dart';

enum AppThemeMode { dark, bright, linen, custom }

class ThemeConfig {
  final AppThemeMode mode;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderColor;
  final Color dividerColor;
  final Color errorColor;

  const ThemeConfig({
    required this.mode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderColor,
    required this.dividerColor,
    required this.errorColor,
  });

  factory ThemeConfig.dark() => const ThemeConfig(
        mode: AppThemeMode.dark,
        primaryColor: Color(0xFF6C63FF),
        secondaryColor: Color(0xFFFF6584),
        accentColor: Color(0xFF43E97B),
        backgroundColor: Color(0xFF0F0F1A),
        surfaceColor: Color(0xFF1A1A2E),
        cardColor: Color(0xFF16213E),
        textPrimary: Color(0xFFF0F0F5),
        textSecondary: Color(0xFFAAAAAF),
        textTertiary: Color(0xFF666680),
        borderColor: Color(0xFF2A2A4A),
        dividerColor: Color(0xFF1E1E35),
        errorColor: Color(0xFFFF4757),
      );

  factory ThemeConfig.bright() => const ThemeConfig(
        mode: AppThemeMode.bright,
        primaryColor: Color(0xFF6C63FF),
        secondaryColor: Color(0xFFFF6584),
        accentColor: Color(0xFF2ECC71),
        backgroundColor: Color(0xFFF8F9FC),
        surfaceColor: Color(0xFFFFFFFF),
        cardColor: Color(0xFFF0F2F8),
        textPrimary: Color(0xFF1A1A2E),
        textSecondary: Color(0xFF5A5A72),
        textTertiary: Color(0xFF9090A8),
        borderColor: Color(0xFFE2E4EE),
        dividerColor: Color(0xFFEAEAF0),
        errorColor: Color(0xFFE53935),
      );

  factory ThemeConfig.linen() => const ThemeConfig(
        mode: AppThemeMode.linen,
        primaryColor: Color(0xFFB87A5C),
        secondaryColor: Color(0xFFD4A574),
        accentColor: Color(0xFF7A9E7E),
        backgroundColor: Color(0xFFF5F0E8),
        surfaceColor: Color(0xFFEDE6DA),
        cardColor: Color(0xFFE8DFD0),
        textPrimary: Color(0xFF3D3229),
        textSecondary: Color(0xFF6B5E52),
        textTertiary: Color(0xFF9A8B7D),
        borderColor: Color(0xFFD9CFC0),
        dividerColor: Color(0xFFE5DDD2),
        errorColor: Color(0xFFC0392B),
      );

  factory ThemeConfig.custom(Color seed) {
    final bg = _blend(seed, Colors.white, 0.92);
    final surface = _blend(seed, Colors.white, 0.85);
    final card = _blend(seed, Colors.white, 0.78);
    final textPrimary = _contrastText(bg);
    final textSecondary = Color.alphaBlend(
      textPrimary.withValues(alpha: 0.55),
      bg,
    );
    final textTertiary = Color.alphaBlend(
      textPrimary.withValues(alpha: 0.38),
      bg,
    );
    return ThemeConfig(
      mode: AppThemeMode.custom,
      primaryColor: seed,
      secondaryColor: _blend(seed, const Color(0xFFFF6584), 0.35),
      accentColor: _blend(seed, const Color(0xFF43E97B), 0.35),
      backgroundColor: bg,
      surfaceColor: surface,
      cardColor: card,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      borderColor: _blend(seed, textPrimary, 0.15),
      dividerColor: _blend(seed, textPrimary, 0.08),
      errorColor: const Color(0xFFE53935),
    );
  }

  static Color _contrastText(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFF0F0F5);
  }

  static Color _blend(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, _blend(primaryColor, secondaryColor, 0.5)],
      );

  LinearGradient get darkOverlay => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          textPrimary.withValues(alpha: 0.75),
        ],
      );

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'customPrimary': primaryColor.toARGB32(),
      };

  static ThemeConfig fromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String? ?? 'dark';
    final mode = AppThemeMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => AppThemeMode.dark,
    );
    switch (mode) {
      case AppThemeMode.bright:
        return ThemeConfig.bright();
      case AppThemeMode.linen:
        return ThemeConfig.linen();
      case AppThemeMode.custom:
        final colorValue = json['customPrimary'] as int?;
        if (colorValue != null) {
          return ThemeConfig.custom(Color(colorValue));
        }
        return ThemeConfig.dark();
      case AppThemeMode.dark:
        return ThemeConfig.dark();
    }
  }
}
