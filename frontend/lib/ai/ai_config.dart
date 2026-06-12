import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini API configuration for sticker and avatar generation.
///
/// Set in `frontend/.env`:
/// `GEMINI_API_KEY=your_key_here`
///
/// Or at run time: `flutter run --dart-define=GEMINI_API_KEY=your_key`
class AiConfig {
  static String get apiKey {
    final fromDotEnv = dotenv.env['GEMINI_API_KEY']?.trim();
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) return fromDotEnv;

    const fromDefine = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    );
    return fromDefine;
  }

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Image-capable Gemini model for sticker/avatar generation.
  /// Uses the experimental Flash model which supports responseModalities: IMAGE.
  static const String imageModel = 'gemini-2.0-flash-exp';

  /// Fallback text model for descriptions when image output is unavailable.
  static const String textModel = 'gemini-2.0-flash';
}
