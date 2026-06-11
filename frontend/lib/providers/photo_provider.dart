import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

/// Stream of user's photos from Firestore
final photosStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getPhotosStream();
});

/// Upload state notifier
class PhotoUploadNotifier extends StateNotifier<AsyncValue<void>> {
  final StorageService _storageService;

  PhotoUploadNotifier(this._storageService) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> uploadPhoto(String filePath) async {
    state = const AsyncValue.loading();
    try {
      final result = await _storageService.savePhoto(filePath);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final photoUploadProvider =
    StateNotifierProvider<PhotoUploadNotifier, AsyncValue<void>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return PhotoUploadNotifier(storageService);
});

/// Delete state notifier
class PhotoDeleteNotifier extends StateNotifier<AsyncValue<void>> {
  final StorageService _storageService;

  PhotoDeleteNotifier(this._storageService) : super(const AsyncValue.data(null));

  Future<void> deletePhoto(String photoId, String storagePath) async {
    state = const AsyncValue.loading();
    try {
      await _storageService.deletePhoto(photoId, storagePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final photoDeleteProvider =
    StateNotifierProvider<PhotoDeleteNotifier, AsyncValue<void>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return PhotoDeleteNotifier(storageService);
});
