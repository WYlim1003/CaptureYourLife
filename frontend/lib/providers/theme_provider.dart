import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../config/theme_config.dart';

const _themeKey = 'app_theme_config';
const _onboardingKey = 'onboarding_complete';

final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, ThemeConfig>((ref) {
  return ThemeConfigNotifier();
});

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  return AppTheme.fromConfig(config);
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingKey) ?? false;
});

class ThemeConfigNotifier extends StateNotifier<ThemeConfig> {
  ThemeConfigNotifier() : super(ThemeConfig.dark()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeKey);
    if (raw != null) {
      try {
        final config = ThemeConfig.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        state = config;
        AppColors.apply(config);
      } catch (_) {}
    } else {
      AppColors.apply(state);
    }
  }

  Future<void> setTheme(ThemeConfig config) async {
    state = config;
    AppColors.apply(config);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, jsonEncode(config.toJson()));
  }

  Future<void> setDark() => setTheme(ThemeConfig.dark());
  Future<void> setBright() => setTheme(ThemeConfig.bright());
  Future<void> setLinen() => setTheme(ThemeConfig.linen());
  Future<void> setCustom(Color color) => setTheme(ThemeConfig.custom(color));
}

Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingKey, true);
}

Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingKey) ?? false;
}
