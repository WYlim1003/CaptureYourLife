import 'package:cross_file/cross_file.dart';

// On web: uses WebRTC getUserMedia for a real camera preview + capture.
// On non-web: this module is replaced by the stub (no-op).
import 'web_camera_capture_web.dart'
    if (dart.library.io) 'web_camera_capture_stub.dart' as impl;

Future<XFile?> captureFromWebCamera() => impl.captureFromWebCamera();
