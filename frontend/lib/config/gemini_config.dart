import '../ai/ai_config.dart';

/// Backwards-compatible alias for [AiConfig].
class GeminiConfig {
  static String get apiKey => AiConfig.apiKey;
  static bool get isConfigured => AiConfig.isConfigured;
  static String get imageModel => AiConfig.imageModel;
}
