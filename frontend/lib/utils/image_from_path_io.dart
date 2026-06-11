import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

Widget buildImageFromPath({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(path),
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
  await File(sourcePath).copy(destinationPath);
}

Future<void> deleteLocalPhoto(String localPath) async {
  final file = File(localPath);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<bool> localPhotoExists(String localPath) async {
  return File(localPath).exists();
}

Future<XFile> toShareableFile(String localPath) async {
  return XFile(localPath);
}
