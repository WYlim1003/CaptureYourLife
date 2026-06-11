import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> _ensureCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      throw Exception(
        'Camera permission denied. Enable it in device Settings.',
      );
    }
    throw Exception('Camera permission is required to take photos.');
  }

  Future<bool> _ensureGalleryPermission() async {
    if (kIsWeb) return true;
    final photos = await Permission.photos.status;
    if (photos.isGranted || photos.isLimited) return true;
    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    final photosResult = await Permission.photos.request();
    if (photosResult.isGranted || photosResult.isLimited) return true;

    final storageResult = await Permission.storage.request();
    if (storageResult.isGranted) return true;

    return true; // image_picker may still work on some devices
  }

  Future<XFile?> pickImageFromCamera() async {
    await _ensureCameraPermission();
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );
  }

  Future<XFile?> pickImageFromGallery() async {
    await _ensureGalleryPermission();
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  Future<List<XFile>?> pickMultipleImages() async {
    await _ensureGalleryPermission();
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    return images.isNotEmpty ? images : null;
  }
}
