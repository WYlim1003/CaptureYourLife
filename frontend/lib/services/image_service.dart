import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import '../utils/web_camera_capture.dart';

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  /// On web (desktop Chrome), image_picker's ImageSource.camera only opens
  /// the file picker — desktop browsers ignore the HTML `capture` attribute.
  /// We use a custom WebRTC getUserMedia overlay on web instead.
  /// On Android/iOS, image_picker opens the native camera directly.
  Future<XFile?> pickImageFromCamera() async {
    if (kIsWeb) {
      return captureFromWebCamera();
    }
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );
  }

  Future<XFile?> pickImageFromGallery() async {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  Future<List<XFile>?> pickMultipleImages() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    return images.isNotEmpty ? images : null;
  }
}
