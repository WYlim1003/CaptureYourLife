import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

final imageServiceProvider = Provider((ref) => ImageService());

final selectedImageProvider = StateProvider<XFile?>((ref) => null);

final uploadedImageIdProvider = StateProvider<String?>((ref) => null);

final imagePickerNotifierProvider =
    StateNotifierProvider<ImagePickerNotifier, AsyncValue<XFile?>>((ref) {
  final imageService = ref.watch(imageServiceProvider);
  return ImagePickerNotifier(imageService);
});

class ImagePickerNotifier extends StateNotifier<AsyncValue<XFile?>> {
  final ImageService _imageService;

  ImagePickerNotifier(this._imageService) : super(const AsyncValue.data(null));

  Future<void> pickFromCamera() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _imageService.pickImageFromCamera(),
    );
  }

  Future<void> pickFromGallery() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _imageService.pickImageFromGallery(),
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
