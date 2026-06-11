import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../config/theme_config.dart';
import '../providers/theme_provider.dart';

class ThemePickerPage extends ConsumerStatefulWidget {
  const ThemePickerPage({super.key});

  @override
  ConsumerState<ThemePickerPage> createState() => _ThemePickerPageState();
}

class _ThemePickerPageState extends ConsumerState<ThemePickerPage> {
  AppThemeMode _selected = AppThemeMode.dark;
  Color _customColor = const Color(0xFF6C63FF);

  ThemeConfig get _previewConfig {
    switch (_selected) {
      case AppThemeMode.bright:
        return ThemeConfig.bright();
      case AppThemeMode.linen:
        return ThemeConfig.linen();
      case AppThemeMode.custom:
        return ThemeConfig.custom(_customColor);
      case AppThemeMode.dark:
        return ThemeConfig.dark();
    }
  }

  Future<void> _applyAndContinue() async {
    final notifier = ref.read(themeConfigProvider.notifier);
    switch (_selected) {
      case AppThemeMode.dark:
        await notifier.setDark();
      case AppThemeMode.bright:
        await notifier.setBright();
      case AppThemeMode.linen:
        await notifier.setLinen();
      case AppThemeMode.custom:
        await notifier.setCustom(_customColor);
    }
    await markOnboardingComplete();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewConfig;

    return Theme(
      data: AppTheme.fromConfig(preview),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: preview.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your theme',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: preview.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick a look — text colours adapt automatically.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: preview.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PreviewCard(config: preview),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          _ThemeTile(
                            title: 'Dark Mode',
                            subtitle: 'Premium deep dark',
                            icon: Icons.dark_mode_outlined,
                            selected: _selected == AppThemeMode.dark,
                            onTap: () =>
                                setState(() => _selected = AppThemeMode.dark),
                          ),
                          _ThemeTile(
                            title: 'Bright Mode',
                            subtitle: 'Clean and light',
                            icon: Icons.light_mode_outlined,
                            selected: _selected == AppThemeMode.bright,
                            onTap: () =>
                                setState(() => _selected = AppThemeMode.bright),
                          ),
                          _ThemeTile(
                            title: 'Linen Mode',
                            subtitle: 'Warm natural tones',
                            icon: Icons.eco_outlined,
                            selected: _selected == AppThemeMode.linen,
                            onTap: () =>
                                setState(() => _selected = AppThemeMode.linen),
                          ),
                          _ThemeTile(
                            title: 'Custom Theme',
                            subtitle: 'Pick your own colour',
                            icon: Icons.palette_outlined,
                            selected: _selected == AppThemeMode.custom,
                            onTap: () =>
                                setState(() => _selected = AppThemeMode.custom),
                          ),
                          if (_selected == AppThemeMode.custom) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Choose accent colour',
                              style: GoogleFonts.outfit(
                                color: preview.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ColorPicker(
                              pickerColor: _customColor,
                              onColorChanged: (c) =>
                                  setState(() => _customColor = c),
                              enableAlpha: false,
                              labelTypes: const [],
                              pickerAreaHeightPercent: 0.7,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _applyAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: preview.primaryColor,
                          foregroundColor:
                              preview.primaryColor.computeLuminance() > 0.5
                                  ? Colors.black87
                                  : Colors.white,
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final ThemeConfig config;
  const _PreviewCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: config.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Secondary text adapts to background',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: config.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: config.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Primary button',
              style: GoogleFonts.outfit(
                color: config.textPrimary.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? AppColors.primaryColor.withValues(alpha: 0.12)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primaryColor : AppColors.borderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
