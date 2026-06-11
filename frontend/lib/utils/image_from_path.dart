import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

import 'image_from_path_io.dart' if (dart.library.html) 'image_from_path_web.dart'
    as platform;

/// Displays an image from a local path (file path on mobile, blob/http on web).
class ImageFromPath extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  const ImageFromPath({
    required this.path,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return errorBuilder?.call(context, Object(), StackTrace.current) ??
          const SizedBox.shrink();
    }
    return platform.buildImageFromPath(
      path: path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}

bool get isWebPlatform => kIsWeb;

Future<void> copyPhotoToStorage({
  required String sourcePath,
  required String destinationPath,
}) =>
    platform.copyPhotoToStorage(
      sourcePath: sourcePath,
      destinationPath: destinationPath,
    );

Future<void> deleteLocalPhoto(String localPath) =>
    platform.deleteLocalPhoto(localPath);

Future<bool> localPhotoExists(String localPath) =>
    platform.localPhotoExists(localPath);

Future<XFile> toShareableFile(String localPath) =>
    platform.toShareableFile(localPath);
