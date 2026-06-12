import '../ai/ai_agent.dart';

/// Backwards-compatible wrapper around [AiAgent].
class GeminiService {
  final AiAgent _agent = AiAgent();

  Future<Map<String, dynamic>> generateSticker(String imagePath) {
    return _agent.generateSticker(imagePath);
  }

  Future<Map<String, dynamic>> generateAvatar(
    String imagePath,
    String style,
  ) {
    return _agent.generateAvatar(imagePath, style);
  }
}
