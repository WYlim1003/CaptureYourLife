import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import './auth_provider.dart';

final generationNotifierProvider =
    StateNotifierProvider<GenerationNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GenerationNotifier(apiService);
});

final generationHistoryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.getGenerationHistory();
  } catch (e) {
    return {'generations': []};
  }
});

final selectedStyleProvider = StateProvider<String>((ref) => 'anime');

class GenerationNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiService _apiService;

  GenerationNotifier(this._apiService) : super(const AsyncValue.data({}));

  Future<void> generateSticker(String imageId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _apiService.generateSticker(imageId),
    );
  }

  Future<void> generateAvatar(String imageId, String style) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _apiService.generateAvatar(imageId, style),
    );
  }

  void reset() {
    state = const AsyncValue.data({});
  }
}
