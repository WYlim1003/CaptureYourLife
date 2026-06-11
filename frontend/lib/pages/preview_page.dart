import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class PreviewPage extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> generationResult;

  const PreviewPage({
    required this.generationResult,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Your Creation',
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
          padding: const EdgeInsets.all(20),
          child: generationResult.when(
            data: (data) {
              final resultUrl = data['result_url'];
              return Column(
                children: [
                  // Result image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: resultUrl != null
                        ? Image.network(
                            resultUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 320,
                            errorBuilder: (_, __, ___) => Container(
                              height: 320,
                              color: AppColors.cardColor,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.textTertiary, size: 48),
                              ),
                            ),
                          )
                        : Container(
                            height: 320,
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: AppColors.textTertiary, size: 48),
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloaded!',
                                style: GoogleFonts.outfit()),
                            backgroundColor: AppColors.accentColor,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text('Download',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (_) => false),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text('Create Another',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.errorColor, size: 48),
                    const SizedBox(height: 12),
                    Text('Error: $error',
                        style:
                            const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
