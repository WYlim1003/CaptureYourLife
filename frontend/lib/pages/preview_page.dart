import 'dart:typed_data';
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
          icon: Icon(Icons.arrow_back_ios_new,
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
              final resultUrl = data['result_url'] as String?;
              final resultBytes = data['result_bytes'] as Uint8List?;
              final resultText = data['result_text'] as String?;

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _ResultContent(
                      resultUrl: resultUrl,
                      resultBytes: resultBytes,
                      resultText: resultText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved to your creations!',
                              style: GoogleFonts.outfit(),
                            ),
                            backgroundColor: AppColors.accentColor,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(
                        'Save',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (_) => false,
                      ),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(
                        'Create Another',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => SizedBox(
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
                    Icon(Icons.error_outline,
                        color: AppColors.errorColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Error: $error',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
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

class _ResultContent extends StatelessWidget {
  final String? resultUrl;
  final Uint8List? resultBytes;
  final String? resultText;

  const _ResultContent({
    this.resultUrl,
    this.resultBytes,
    this.resultText,
  });

  @override
  Widget build(BuildContext context) {
    if (resultBytes != null) {
      return Image.memory(
        resultBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 320,
      );
    }
    if (resultUrl != null) {
      return Image.network(
        resultUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 320,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (resultText != null && resultText!.isNotEmpty) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          resultText!,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textTertiary,
          size: 48,
        ),
      ),
    );
  }
}
