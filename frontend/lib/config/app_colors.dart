import 'package:flutter/material.dart';
import 'theme_config.dart';

/// Dynamic color palette — updated when the user changes theme.
class AppColors {
  static ThemeConfig _config = ThemeConfig.dark();

  static void apply(ThemeConfig config) => _config = config;

  static Color get primaryColor => _config.primaryColor;
  static Color get primaryLight =>
      Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
  static Color get primaryDark =>
      Color.lerp(primaryColor, Colors.black, 0.25) ?? primaryColor;

  static Color get secondaryColor => _config.secondaryColor;
  static Color get accentColor => _config.accentColor;

  static Color get backgroundColor => _config.backgroundColor;
  static Color get surfaceColor => _config.surfaceColor;
  static Color get cardColor => _config.cardColor;
  static Color get overlayColor => _config.backgroundColor;

  static Color get errorColor => _config.errorColor;

  static Color get textPrimary => _config.textPrimary;
  static Color get textSecondary => _config.textSecondary;
  static Color get textTertiary => _config.textTertiary;

  static Color get borderColor => _config.borderColor;
  static Color get dividerColor => _config.dividerColor;

  static LinearGradient get primaryGradient => _config.primaryGradient;
  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surfaceColor, cardColor],
      );
  static LinearGradient get darkOverlay => _config.darkOverlay;
}
