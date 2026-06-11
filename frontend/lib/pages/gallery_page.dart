import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../providers/photo_provider.dart';
import '../providers/firebase_auth_provider.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosStreamProvider);

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
          'My Gallery',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: AppColors.textSecondary, size: 20),
            onPressed: () async {
              await ref.read(authNotifierV2Provider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: photosAsync.when(
          data: (photos) {
            if (photos.isEmpty) {
              return _EmptyGallery(
                  onAdd: () => Navigator.pushNamed(context, '/camera'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return _GalleryItem(
                  photo: photo,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/photo_detail',
                    arguments: photo,
                  ),
                  onDelete: () => _confirmDelete(context, ref, photo),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Photo?',
          style: GoogleFonts.outfit(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This photo will be permanently removed.',
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
                    photo['id'] ?? '',
                    photo['local_path'] ?? '',
                  );
            },
            child: Text('Delete',
                style:
                    GoogleFonts.outfit(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final Map<String, dynamic> photo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GalleryItem({
    required this.photo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = photo['created_at'];
    final dateStr = createdAt is DateTime
        ? DateFormat('MMM d').format(createdAt)
        : '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo['local_path'] ?? ''),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.cardColor,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.textTertiary, size: 24),
              ),
            ),
            // Date overlay
            if (dateStr.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 6),
                  decoration: const BoxDecoration(
                    gradient: AppColors.darkOverlay,
                  ),
                  child: Text(
                    dateStr,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGallery({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(Icons.photo_library_outlined,
                  color: AppColors.textTertiary, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              'No photos yet',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture your first moment and it will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: Text('Take a Photo',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
