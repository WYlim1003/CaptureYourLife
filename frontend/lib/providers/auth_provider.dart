import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

final isLoggedInProvider = FutureProvider((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isLoggedIn();
});

final userIdProvider = FutureProvider((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserId();
});

final usernameProvider = FutureProvider((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUsername();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> register(String email, String password, String username) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.register(email, password, username),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.login(email, password),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authService.logout(),
    );
  }
}
