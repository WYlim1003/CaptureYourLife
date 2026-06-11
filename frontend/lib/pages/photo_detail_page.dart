import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../providers/photo_provider.dart';
import '../utils/image_from_path.dart';

class PhotoDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> photo;
  const PhotoDetailPage({required this.photo, super.key});

  @override
  ConsumerState<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends ConsumerState<PhotoDetailPage> {
  bool _isSaving = false;
  bool _isSharing = false;
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final createdAt = photo['created_at'];
    final dateStr = createdAt is DateTime
        ? DateFormat('MMMM d, yyyy • h:mm a').format(createdAt)
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                children: [
                  Text(
                    'Photo',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.white60),
                    ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white70, size: 22),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: ImageFromPath(
              path: photo['local_path'] ?? '',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.white54, size: 64),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _showControls
          ? Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.download_outlined,
                      label: _isSaving ? 'Saving...' : 'Save',
                      isLoading: _isSaving,
                      onTap: _isSaving ? null : () => _saveToGallery(photo['local_path']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.share_outlined,
                      label: _isSharing ? 'Sharing...' : 'Share',
                      isLoading: _isSharing,
                      onTap: _isSharing ? null : () => _sharePhoto(photo['local_path']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.auto_awesome,
                      label: 'AI Edit',
                      onTap: () {
                        final path = photo['local_path'] as String?;
                        if (path != null && path.isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            '/editor',
                            arguments: path,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Future<void> _saveToGallery(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save to gallery is available on mobile only.',
              style: GoogleFonts.outfit()),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      if (!await localPhotoExists(localPath)) {
        throw Exception('File not found');
      }
      await Gal.putImage(localPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to gallery! 📸',
                style: GoogleFonts.outfit()),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sharePhoto(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return;
    setState(() => _isSharing = true);
    try {
      if (!await localPhotoExists(localPath)) {
        throw Exception('File not found');
      }
      final file = await toShareableFile(localPath);
      await Share.shareXFiles(
        [file],
        text: 'Check out my photo from CaptureYourLife! 📸',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Photo?',
          style: GoogleFonts.outfit(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will permanently delete the photo.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(photoDeleteProvider.notifier).deletePhoto(
                    widget.photo['id'] ?? '',
                    widget.photo['local_path'] ?? '',
                  );
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: GoogleFonts.outfit(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  const _ActionBtn({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
