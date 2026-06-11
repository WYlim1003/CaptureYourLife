import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// Routes user after successful auth based on verification + onboarding state.
Future<void> navigateAfterAuth(BuildContext context, WidgetRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    return;
  }

  final isGoogle =
      user.providerData.any((p) => p.providerId == 'google.com');
  if (!isGoogle && !user.emailVerified) {
    Navigator.pushNamedAndRemoveUntil(context, '/email_verify', (_) => false);
    return;
  }

  final onboarded = await isOnboardingComplete();
  if (!context.mounted) return;

  if (!onboarded) {
    Navigator.pushNamedAndRemoveUntil(context, '/theme_picker', (_) => false);
    return;
  }

  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
}
