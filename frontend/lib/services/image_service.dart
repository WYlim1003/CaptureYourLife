import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      return images.isNotEmpty ? images : null;
    } catch (e) {
      rethrow;
    }
  }
}
