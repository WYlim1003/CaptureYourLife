import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini API key — set in `frontend/.env`:
/// `GEMINI_API_KEY=your_key_here`
///
/// Or pass at run time: `flutter run --dart-define=GEMINI_API_KEY=your_key`
class GeminiConfig {
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

  static const String imageModel = 'gemini-2.0-flash-exp';
}
