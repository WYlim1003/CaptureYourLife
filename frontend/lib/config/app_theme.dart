import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_config.dart';

class AppTheme {
  static ThemeData fromConfig(ThemeConfig config) {
    final isDark = config.backgroundColor.computeLuminance() < 0.5;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: config.primaryColor,
      scaffoldBackgroundColor: config.backgroundColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: config.primaryColor,
        onPrimary: _onColor(config.primaryColor),
        secondary: config.secondaryColor,
        onSecondary: _onColor(config.secondaryColor),
        surface: config.surfaceColor,
        onSurface: config.textPrimary,
        error: config.errorColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.outfit(
          color: config.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: config.textPrimary),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: config.textPrimary,
        displayColor: config.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: _onColor(config.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.errorColor),
        ),
        labelStyle: TextStyle(color: config.textSecondary),
        hintStyle: TextStyle(color: config.textTertiary),
      ),
      cardTheme: CardThemeData(
        color: config.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: config.borderColor),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: config.dividerColor,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: config.surfaceColor,
        contentTextStyle: GoogleFonts.outfit(color: config.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Legacy accessor — prefer [fromConfig].
  static ThemeData get darkTheme => fromConfig(ThemeConfig.dark());
}
