import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

Widget buildImageFromPath({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.network(
    path,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}

Future<void> copyPhotoToStorage({
  required String sourcePath,
  required String destinationPath,
}) async {
  // Web keeps the picker blob URL as the stored path.
}

Future<void> deleteLocalPhoto(String localPath) async {
  // Blob URLs are managed by the browser; no file deletion needed.
}

Future<bool> localPhotoExists(String localPath) async {
  return localPath.isNotEmpty;
}

Future<XFile> toShareableFile(String localPath) async {
  return XFile(localPath);
}
