import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

final generationNotifierProvider =
    StateNotifierProvider<GenerationNotifier, AsyncValue<Map<String, dynamic>>>(
        (ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return GenerationNotifier(gemini);
});

final selectedStyleProvider = StateProvider<String>((ref) => 'anime');

class GenerationNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final GeminiService _gemini;

  GenerationNotifier(this._gemini) : super(const AsyncValue.data({}));

  Future<void> generateSticker(String imagePath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _gemini.generateSticker(imagePath),
    );
  }

  Future<void> generateAvatar(String imagePath, String style) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _gemini.generateAvatar(imagePath, style),
    );
  }

  void reset() {
    state = const AsyncValue.data({});
  }
}
