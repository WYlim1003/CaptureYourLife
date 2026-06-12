import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../utils/image_from_path.dart';
import 'ai_config.dart';
import 'ai_prompts.dart';

/// AI agent that generates stickers and avatars via the Gemini API.
class AiAgent {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  Future<Map<String, dynamic>> generateSticker(String imagePath) {
    return _generateImage(
      imagePath: imagePath,
      prompt: AiPrompts.sticker,
    );
  }

  Future<Map<String, dynamic>> generateAvatar(
    String imagePath,
    String style,
  ) {
    return _generateImage(
      imagePath: imagePath,
      prompt: AiPrompts.avatar(style),
    );
  }

  Future<Map<String, dynamic>> _generateImage({
    required String imagePath,
    required String prompt,
  }) async {
    if (!AiConfig.isConfigured) {
      throw AiException(
        'Gemini API key not configured. Set GEMINI_API_KEY in frontend/.env',
      );
    }

    final bytes = await _readImageBytes(imagePath);
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(bytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseModalities': ['TEXT', 'IMAGE'],
      },
    };

    final uri = Uri.parse(
      '$_baseUrl/models/${AiConfig.imageModel}:generateContent?key=${AiConfig.apiKey}',
    );

    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));
    } catch (e) {
      throw AiException('Network error while generating image: $e');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AiException(
        'Invalid Gemini API key. Check GEMINI_API_KEY in frontend/.env',
      );
    }

    if (response.statusCode == 404) {
      throw AiException(
        'AI model "${AiConfig.imageModel}" is unavailable. '
        'Please update the app.',
      );
    }

    if (response.statusCode == 429) {
      throw AiException('AI quota exceeded. Please try again later.');
    }

    if (response.statusCode != 200) {
      final message = _extractApiError(response.body);
      throw AiException(message ?? 'AI generation failed (${response.statusCode})');
    }

    return _parseResponse(response.body);
  }

  Map<String, dynamic> _parseResponse(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw AiException('No result from AI. Try a different photo or prompt.');
    }

    final parts =
        (candidates.first as Map<String, dynamic>)['content']?['parts']
            as List<dynamic>? ??
        [];

    String? resultText;
    Uint8List? resultBytes;

    for (final part in parts) {
      final map = part as Map<String, dynamic>;
      if (map.containsKey('text')) {
        resultText = map['text'] as String?;
      }
      final inline = map['inlineData'] ?? map['inline_data'];
      if (inline is Map<String, dynamic>) {
        final data = inline['data'] as String?;
        if (data != null) {
          resultBytes = base64Decode(data);
        }
      }
    }

    if (resultBytes != null) {
      return {
        'status': 'success',
        'result_bytes': resultBytes,
        'result_url': null,
        'type': 'image',
        if (resultText != null) 'result_text': resultText,
      };
    }

    if (resultText != null && resultText.isNotEmpty) {
      return {
        'status': 'success',
        'result_text': resultText,
        'result_url': null,
        'type': 'text',
      };
    }

    throw AiException('No image returned. Try a different photo or prompt.');
  }

  String? _extractApiError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return error?['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _readImageBytes(String path) async {
    final file = await toShareableFile(path);
    return file.readAsBytes();
  }
}

class AiException implements Exception {
  final String message;
  const AiException(this.message);

  @override
  String toString() => message;
}
