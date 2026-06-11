import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';
import '../utils/image_from_path.dart';

class GeminiService {
  GenerativeModel? get _model {
    if (!GeminiConfig.isConfigured) return null;
    return GenerativeModel(
      model: GeminiConfig.imageModel,
      apiKey: GeminiConfig.apiKey,
    );
  }

  Future<Map<String, dynamic>> generateSticker(String imagePath) async {
    return _generate(
      imagePath: imagePath,
      prompt:
          'Transform this photo into a high-quality cute cartoon sticker. '
          'Use bold clean outlines, vibrant colours, and a simple background. '
          'Make it look like a messaging-app sticker.',
    );
  }

  Future<Map<String, dynamic>> generateAvatar(
    String imagePath,
    String style,
  ) async {
    final stylePrompts = {
      'anime': 'anime portrait with cel-shading and expressive eyes',
      'comic': 'comic-book hero portrait with bold ink lines',
      'hand_drawn': 'hand-drawn pencil sketch portrait',
      'watercolor': 'soft watercolor painting portrait',
      'cyberpunk': 'cyberpunk portrait with neon lighting',
    };
    final styleDesc = stylePrompts[style] ?? stylePrompts['anime']!;
    return _generate(
      imagePath: imagePath,
      prompt:
          'Transform this photo into a $styleDesc avatar portrait. '
          'Keep the person recognizable. High quality, artistic.',
    );
  }

  Future<Map<String, dynamic>> _generate({
    required String imagePath,
    required String prompt,
  }) async {
    final model = _model;
    if (model == null) {
      throw Exception(
        'Gemini API key not configured. '
        'Set GEMINI_API_KEY in frontend/.env',
      );
    }

    final bytes = await _readImageBytes(imagePath);
    final response = await model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', bytes),
      ]),
    ]);

    final text = response.text;
    if (text != null && text.isNotEmpty) {
      return {
        'status': 'success',
        'result_text': text,
        'result_url': null,
        'type': 'text',
      };
    }

    for (final part in response.candidates.firstOrNull?.content.parts ?? []) {
      if (part is DataPart) {
        return {
          'status': 'success',
          'result_bytes': part.bytes,
          'result_url': null,
          'type': 'image',
        };
      }
    }

    throw Exception('No result from Gemini. Try a different photo or prompt.');
  }

  Future<Uint8List> _readImageBytes(String path) async {
    if (isWebPlatform) {
      final file = await toShareableFile(path);
      return file.readAsBytes();
    }
    final file = await toShareableFile(path);
    return file.readAsBytes();
  }
}
