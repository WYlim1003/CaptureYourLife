import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../components/image_picker_widget.dart';
import '../components/image_preview.dart';
import '../components/primary_button.dart';
import '../providers/image_provider.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickerState = ref.watch(imagePickerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Select Image',
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
            child: Column(
              children: [
                pickerState.when(
                  data: (image) {
                    if (image == null) {
                      return ImagePickerWidget(
                        onCameraPressed: () =>
                            ref.read(imagePickerNotifierProvider.notifier).pickFromCamera(),
                        onGalleryPressed: () =>
                            ref.read(imagePickerNotifierProvider.notifier).pickFromGallery(),
                      );
                    } else {
                      return Column(
                        children: [
                          ImagePreview(
                            imagePath: image.path,
                            title: 'Selected Image',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Change',
                                  onPressed: () => ref
                                      .read(imagePickerNotifierProvider.notifier)
                                      .reset(),
                                  backgroundColor: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Continue',
                                  onPressed: () {
                                    ref.read(selectedImageProvider.notifier).state =
                                        image;
                                    Navigator.pushNamed(
                                      context,
                                      '/editor',
                                      arguments: image.path,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                  loading: () => ImagePickerWidget(
                    onCameraPressed: () {},
                    onGalleryPressed: () {},
                    isLoading: true,
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorColor,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: AppColors.errorColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Retry',
                          onPressed: () => ref
                              .read(imagePickerNotifierProvider.notifier)
                              .reset(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
