// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:cross_file/cross_file.dart';

/// Opens a full-screen camera overlay using the browser WebRTC API.
/// Works on desktop Chrome where image_picker's ImageSource.camera only
/// opens the file picker (browsers ignore the `capture` attribute on desktop).
Future<XFile?> captureFromWebCamera() async {
  html.MediaStream? stream;

  // ── 1. Request camera access ─────────────────────────────────────────────
  try {
    stream = await html.window.navigator.mediaDevices!.getUserMedia({
      'video': {
        'facingMode': {'ideal': 'environment'},
        'width': {'ideal': 1920},
        'height': {'ideal': 1080},
      },
      'audio': false,
    });
  } catch (_) {
    // Try any camera if rear isn't available (desktop often only has front cam)
    try {
      stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': true, 'audio': false});
    } catch (e) {
      return null; // Camera access denied
    }
  }

  final completer = Completer<XFile?>();

  // ── 2. Build the HTML overlay ────────────────────────────────────────────
  final overlay = _el('div', {
    'position': 'fixed',
    'inset': '0',
    'background': 'rgba(0,0,0,0.97)',
    'z-index': '2147483647',
    'display': 'flex',
    'flex-direction': 'column',
    'align-items': 'center',
    'justify-content': 'center',
    'font-family': "'Outfit', 'Inter', sans-serif",
  });

  // Header
  final header = html.DivElement()
    ..style.color = '#e2e8f0'
    ..style.fontSize = '15px'
    ..style.marginBottom = '16px'
    ..style.letterSpacing = '0.5px'
    ..text = 'Position your subject and tap capture';

  // Video wrapper
  final videoWrapper = _el('div', {
    'position': 'relative',
    'width': '100%',
    'max-width': '640px',
    'border-radius': '20px',
    'overflow': 'hidden',
    'box-shadow': '0 0 60px rgba(124,58,237,0.4)',
    'border': '2px solid rgba(124,58,237,0.5)',
  });

  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true;
  video.style
    ..width = '100%'
    ..display = 'block';
  video.srcObject = stream;

  videoWrapper.children.add(video);

  // Buttons row
  final btnRow = _el('div', {
    'display': 'flex',
    'gap': '16px',
    'margin-top': '28px',
    'align-items': 'center',
  });

  // Cancel button
  final cancelBtn = html.ButtonElement()..text = 'Cancel';
  cancelBtn.style
    ..padding = '12px 28px'
    ..fontSize = '14px'
    ..fontWeight = '600'
    ..background = 'transparent'
    ..color = '#94a3b8'
    ..border = '1px solid #334155'
    ..borderRadius = '50px'
    ..cursor = 'pointer'
    ..fontFamily = "'Outfit', 'Inter', sans-serif";

  // Capture button (big purple circle)
  final captureBtn = html.ButtonElement();
  captureBtn.style
    ..width = '76px'
    ..height = '76px'
    ..borderRadius = '50%'
    ..background = 'linear-gradient(135deg, #7C3AED, #9F67FA)'
    ..border = '4px solid rgba(255,255,255,0.25)'
    ..boxShadow = '0 0 30px rgba(124,58,237,0.6)'
    ..cursor = 'pointer'
    ..fontSize = '28px'
    ..display = 'flex'
    ..alignItems = 'center'
    ..justifyContent = 'center'
    ..transition = 'transform 0.1s';
  captureBtn.innerHtml = '📸';

  btnRow.children.addAll([cancelBtn, captureBtn]);
  overlay.children.addAll([header, videoWrapper, btnRow]);
  html.document.body!.children.add(overlay);

  // ── 3. Wait for video to be ready ───────────────────────────────────────
  video.onLoadedMetadata.listen((_) {
    // Video is ready — no action needed
  });

  // ── 4. Capture button handler ────────────────────────────────────────────
  captureBtn.onMouseDown.listen((_) {
    captureBtn.style.transform = 'scale(0.92)';
  });
  captureBtn.onMouseUp.listen((_) {
    captureBtn.style.transform = 'scale(1)';
  });

  captureBtn.onClick.listen((_) async {
    if (completer.isCompleted) return;

    final w = video.videoWidth;
    final h = video.videoHeight;
    if (w == 0 || h == 0) return; // Video not ready yet

    // Draw current frame to canvas
    final canvas = html.CanvasElement(width: w, height: h);
    canvas.context2D.drawImage(video, 0, 0);

    // Get JPEG data URL and convert to bytes
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
    final base64Str = dataUrl.split(',').last;
    final bytes = base64Decode(base64Str);

    _cleanup(stream, overlay);
    completer.complete(
      XFile.fromData(
        bytes,
        mimeType: 'image/jpeg',
        name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
  });

  // ── 5. Cancel handler ────────────────────────────────────────────────────
  cancelBtn.onClick.listen((_) {
    if (completer.isCompleted) return;
    _cleanup(stream, overlay);
    completer.complete(null);
  });

  return completer.future;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

html.DivElement _el(String tag, Map<String, String> styles) {
  final el = html.DivElement();
  styles.forEach((k, v) => el.style.setProperty(k, v));
  return el;
}

void _cleanup(html.MediaStream? stream, html.Element overlay) {
  stream?.getTracks().forEach((t) => t.stop());
  overlay.remove();
}
