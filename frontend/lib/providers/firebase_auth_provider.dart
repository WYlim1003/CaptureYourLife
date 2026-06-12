import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
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
  // Only used on Android/iOS — on web we use FirebaseAuth.signInWithPopup() directly.
  final GoogleSignIn _googleSignIn = kIsWeb
    ? GoogleSignIn(
        scopes: const ['email', 'profile'],
      )
    : GoogleSignIn(
        serverClientId:
            '786561093977-h96fk9t2po8jco3k15j3shmvn3ulsglc.apps.googleusercontent.com',
        scopes: const ['email', 'profile'],
  );

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
      if (kIsWeb) {
        // ── Web path ──────────────────────────────────────────────────────────
        // google_sign_in's signIn() is deprecated on web since Q2 2024 and
        // cannot reliably provide an idToken. Use FirebaseAuth.signInWithPopup()
        // directly — it handles the full OAuth 2.0 popup flow natively.
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        final userCredential = await _auth.signInWithPopup(provider);
        state = AsyncValue.data(userCredential.user);
      } else {
        // ── Mobile path (Android / iOS) ───────────────────────────────────────
        try {
          await _googleSignIn.signOut();
        } catch (_) {}

        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User dismissed the native account picker.
          state = const AsyncValue.data(null);
          return;
        }

        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null) {
          throw Exception(
            'Google did not return an ID token.\n'
            'Make sure:\n'
            '• Google Sign-In is enabled in Firebase Console → Authentication → Sign-in method\n'
            '• Your SHA-1 fingerprint is registered in Firebase Console → Project Settings → Android app',
          );
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        state = AsyncValue.data(userCredential.user);
      }
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(_mapAuthError(e), st);
    } on PlatformException catch (e, st) {
      state = AsyncValue.error(_mapGooglePlatformError(e), st);
    } catch (e, st) {
      state = AsyncValue.error(_mapGoogleError(e), st);
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
    if (!kIsWeb) await _googleSignIn.signOut();
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
      case 'operation-not-allowed':
        return 'Google sign-in is disabled. Enable it in Firebase Console → Authentication → Sign-in method.';
      // Web popup-specific codes
      case 'popup-closed-by-user':
        return 'Sign-in cancelled. Please complete the Google sign-in popup.';
      case 'cancelled-popup-request':
        return 'A sign-in popup is already open.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked by the browser. Please allow popups for this site and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  String _mapGooglePlatformError(PlatformException e) {
    switch (e.code) {
      case 'sign_in_failed':
        return 'Google sign-in failed. Add your app SHA-1 fingerprint in Firebase Console, '
            'then re-download google-services.json.';
      case 'network_error':
        return 'Network error during Google sign-in. Check your connection.';
      case 'sign_in_canceled':
        return 'Google sign-in was cancelled.';
      default:
        return e.message ?? 'Google sign-in failed (${e.code}).';
    }
  }

  String _mapGoogleError(Object e) {
    final message = e.toString();
    if (message.contains('id token')) return message.replaceFirst('Exception: ', '');
    if (kIsWeb && message.contains('popup')) {
      return 'Google sign-in popup was blocked. Allow popups for this site.';
    }
    return 'Google sign-in failed. Enable Google Auth in Firebase Console → Authentication → Sign-in method.';
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
