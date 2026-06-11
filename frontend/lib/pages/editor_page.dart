import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../components/loading_spinner.dart';
import '../providers/generation_provider.dart';
import '../providers/image_provider.dart';

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
  late String selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = 'sticker';
  }

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(generationNotifierProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Coming soon banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.15),
                      AppColors.secondaryColor.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Generation — Coming Soon 🚀',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Stickers, avatars, and styles will be available in the next update.',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab row (disabled)
              Row(
                children: ['Sticker', 'Avatar'].map((tab) {
                  final isSelected = tab.toLowerCase() == selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                          () => selectedTab = tab.toLowerCase()),
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
              const SizedBox(height: 24),

              // Disabled generate button
              generationState.when(
                data: (data) => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: null, // Disabled — AI not yet integrated
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      selectedTab == 'sticker'
                          ? 'Generate Sticker (Coming Soon)'
                          : 'Generate Avatar (Coming Soon)',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.3),
                      disabledBackgroundColor:
                          AppColors.primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                loading: () => const LoadingSpinner(
                    message: 'Generating your creation...'),
                error: (error, _) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: AppColors.errorColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}