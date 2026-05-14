import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../components/image_preview.dart';
import '../components/primary_button.dart';

class PreviewPage extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> generationResult;

  const PreviewPage({
    required this.generationResult,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Your Creation',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: generationResult.when(
              data: (data) {
                final resultUrl = data['result_url'];
                return Column(
                  children: [
                    ImagePreview(
                      imageUrl: resultUrl,
                      title: 'Generated Image',
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Download',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloaded successfully!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Share',
                      backgroundColor: AppColors.secondaryColor,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Create Another',
                      backgroundColor: AppColors.textSecondary,
                      onPressed: () => Navigator.popUntil(
                        context,
                        ModalRoute.withName('/home'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
