import 'package:flutter/material.dart';
import 'dart:io';
import '../config/app_colors.dart';

class ImagePreview extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final String title;
  final VoidCallback? onRetry;

  const ImagePreview({super.key, 
    this.imagePath,
    this.imageUrl,
    this.title = '',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 300,
            color: AppColors.backgroundColor,
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                  )
                : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _ErrorWidget(onRetry: onRetry);
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const _ErrorWidget({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Failed to load image',
            style: TextStyle(color: AppColors.errorColor),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
