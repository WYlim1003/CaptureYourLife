import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../providers/image_provider.dart';
import '../providers/photo_provider.dart';
import '../utils/image_from_path.dart';

class CameraPage extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const CameraPage({
    super.key,
    this.showBackButton = true,
  });

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _uploadAndNavigate(String filePath) async {
    setState(() => _isUploading = true);
    try {
      final result =
          await ref.read(photoUploadProvider.notifier).uploadPhoto(filePath);
      if (!mounted) return;
      setState(() => _isUploading = false);
      if (result != null) {
        ref.read(imagePickerNotifierProvider.notifier).reset();
        Navigator.pushReplacementNamed(
          context,
          '/photo_detail',
          arguments: result,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickerState = ref.watch(imagePickerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton 
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Add Photo',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: pickerState.when(
          data: (image) {
            if (image == null) {
              return ScaleTransition(
                scale: _scaleAnim,
                child: _PickerOptions(
                  onCameraPressed: () => ref
                      .read(imagePickerNotifierProvider.notifier)
                      .pickFromCamera(),
                  onGalleryPressed: () => ref
                      .read(imagePickerNotifierProvider.notifier)
                      .pickFromGallery(),
                ),
              );
            }

            return _ImagePreviewPanel(
              imagePath: image.path,
              isUploading: _isUploading,
              onRetake: () =>
                  ref.read(imagePickerNotifierProvider.notifier).reset(),
              onUpload: () => _uploadAndNavigate(image.path),
              onEditWithAI: () {
                ref.read(imagePickerNotifierProvider.notifier).reset();
                Navigator.pushNamed(context, '/editor', arguments: image.path);
              },
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                Text(
                  'Opening...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.errorColor, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(imagePickerNotifierProvider.notifier).reset(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Picker options screen ───────────────────────────────────────────────────

class _PickerOptions extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  const _PickerOptions(
      {required this.onCameraPressed, required this.onGalleryPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_a_photo,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a photo source',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a new photo or pick from gallery',
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  subtitle: 'Take a photo',
                  color: AppColors.primaryColor,
                  onTap: onCameraPressed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  subtitle: 'Pick from library',
                  color: const Color(0xFFFF6584),
                  onTap: onGalleryPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image preview + action panel ───────────────────────────────────────────

class _ImagePreviewPanel extends StatelessWidget {
  final String imagePath;
  final bool isUploading;
  final VoidCallback onRetake;
  final VoidCallback onUpload;
  final VoidCallback onEditWithAI;

  const _ImagePreviewPanel({
    required this.imagePath,
    required this.isUploading,
    required this.onRetake,
    required this.onUpload,
    required this.onEditWithAI,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ImageFromPath(
                path: imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (isUploading) ...[
                LinearProgressIndicator(
                  backgroundColor: AppColors.surfaceColor,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 10),
                Text('Uploading photo...',
                    style:
                        GoogleFonts.outfit(color: AppColors.textSecondary)),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUploading ? null : onRetake,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Retake',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isUploading ? null : onUpload,
                        icon: const Icon(Icons.cloud_upload_outlined,
                            size: 18),
                        label: Text('Save Photo',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isUploading ? null : onEditWithAI,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text('AI Studio',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: BorderSide(
                        color: AppColors.primaryColor, width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
