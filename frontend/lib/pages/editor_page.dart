import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/gemini_config.dart';
import '../components/loading_spinner.dart';
import '../components/style_selector.dart';
import '../providers/generation_provider.dart';
import '../utils/image_from_path.dart';

class EditorPage extends ConsumerStatefulWidget {
  final String imagePath;

  const EditorPage({
    required this.imagePath,
    super.key,
  });

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  String selectedTab = 'sticker';

  static const _avatarStyles = [
    'anime',
    'comic',
    'hand_drawn',
    'watercolor',
    'cyberpunk',
  ];

  Future<void> _generate() async {
    if (!GeminiConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add your Gemini API key to enable AI Studio.\n'
            'Set GEMINI_API_KEY in frontend/.env',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final notifier = ref.read(generationNotifierProvider.notifier);
    if (selectedTab == 'sticker') {
      await notifier.generateSticker(widget.imagePath);
    } else {
      final style = ref.read(selectedStyleProvider);
      await notifier.generateAvatar(widget.imagePath, style);
    }

    if (!mounted) return;
    final state = ref.read(generationNotifierProvider);
    if (state.hasError) return;
    final data = state.valueOrNull;
    if (data == null || data['status'] != 'success') return;

    Navigator.pushNamed(context, '/preview', arguments: state);
  }

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(generationNotifierProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);
    final isLoading = generationState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Studio',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const LoadingSpinner(message: 'Creating your masterpiece...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 260,
                        child: ImageFromPath(
                          path: widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: GeminiConfig.isConfigured
                            ? AppColors.accentColor.withValues(alpha: 0.12)
                            : AppColors.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: GeminiConfig.isConfigured
                              ? AppColors.accentColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            GeminiConfig.isConfigured
                                ? Icons.auto_awesome
                                : Icons.key_outlined,
                            color: GeminiConfig.isConfigured
                                ? AppColors.accentColor
                                : AppColors.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              GeminiConfig.isConfigured
                                  ? 'Phase 2 AI Studio is active — powered by Gemini'
                                  : 'Add GEMINI_API_KEY to frontend/.env',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: ['Sticker', 'Avatar'].map((tab) {
                        final key = tab.toLowerCase();
                        final isSelected = key == selectedTab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = key),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                tab,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (selectedTab == 'avatar') ...[
                      StyleSelector(
                        styles: _avatarStyles,
                        selectedStyle: selectedStyle,
                        onStyleSelected: (s) =>
                            ref.read(selectedStyleProvider.notifier).state = s,
                      ),
                      const SizedBox(height: 20),
                    ],
                    generationState.when(
                      data: (_) => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _generate,
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text(
                              selectedTab == 'sticker'
                                  ? 'Generate Sticker'
                                  : 'Generate Avatar',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (error, _) => Column(
                        children: [
                          Text(
                            'Error: $error',
                            style: TextStyle(color: AppColors.errorColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(generationNotifierProvider.notifier)
                                .reset(),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
