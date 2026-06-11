import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Current Firebase auth user stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Auth notifier for login, register, Google sign-in, logout
class AuthNotifierV2 extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthNotifierV2() : super(const AsyncValue.data(null));

  static bool isGmailAddress(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized.endsWith('@gmail.com') ||
        normalized.endsWith('@googlemail.com');
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    if (!isGmailAddress(email)) {
      state = AsyncValue.error(
        'Please use a Gmail address (@gmail.com) to register.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.sendEmailVerification();
      await credential.user?.reload();
      state = AsyncValue.data(_auth.currentUser);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(_mapAuthError(e), st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = AsyncValue.data(credential.user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(_mapAuthError(e), st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(_mapAuthError(e), st);
    } catch (e, st) {
      state = AsyncValue.error(
        'Google sign-in failed. Enable Google Auth in Firebase Console.',
        st,
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }
    await user.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  void clearError() {
    state = const AsyncValue.data(null);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

final authNotifierV2Provider =
    StateNotifierProvider<AuthNotifierV2, AsyncValue<User?>>((ref) {
  return AuthNotifierV2();
});

/// Whether the current user still needs email verification.
final needsEmailVerificationProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  final isGoogle =
      user.providerData.any((p) => p.providerId == 'google.com');
  if (isGoogle) return false;
  return !user.emailVerified;
});
