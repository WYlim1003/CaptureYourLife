/// Prompt templates for the AI sticker and avatar agent.
class AiPrompts {
  static const sticker = '''
Transform this photo into a high-quality cute cartoon sticker.
Use bold clean outlines, vibrant colours, and a simple background.
Make it look like a messaging-app sticker.
Output a single sticker image.''';

  static String avatar(String style) {
    final styleDesc = _styleDescriptions[style] ?? _styleDescriptions['anime']!;
    return '''
Transform this photo into a $styleDesc avatar portrait.
Keep the person recognizable. High quality, artistic.
Output a single portrait image.''';
  }

  static const _styleDescriptions = {
    'anime': 'anime portrait with cel-shading and expressive eyes',
    'comic': 'comic-book hero portrait with bold ink lines',
    'hand_drawn': 'hand-drawn pencil sketch portrait',
    'watercolor': 'soft watercolor painting portrait',
    'cyberpunk': 'cyberpunk portrait with neon lighting',
  };
}
