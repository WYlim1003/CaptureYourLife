import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/camera_page.dart';
import 'pages/gallery_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/photo_detail_page.dart';
import 'pages/editor_page.dart';
import 'pages/preview_page.dart';
import 'providers/firebase_auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CaptureYourLife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (user) => user != null ? const HomePage() : const LoginPage(),
        loading: () => const _SplashScreen(),
        error: (_, __) => const LoginPage(),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return _fadeRoute(const HomePage());
          case '/camera':
            return _fadeRoute(const CameraPage());
          case '/gallery':
            return _fadeRoute(const GalleryPage());
          case '/login':
            return _fadeRoute(const LoginPage());
          case '/register':
            return _fadeRoute(const RegisterPage());
          case '/editor':
            final imagePath = settings.arguments as String;
            return _fadeRoute(EditorPage(imagePath: imagePath));
          case '/photo_detail':
            final photo = settings.arguments as Map<String, dynamic>;
            return _fadeRoute(PhotoDetailPage(photo: photo));
          case '/preview':
            final generationResult =
                settings.arguments as AsyncValue<Map<String, dynamic>>;
            return _fadeRoute(PreviewPage(generationResult: generationResult));
          default:
            return _fadeRoute(const HomePage());
        }
      },
    );
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D50BB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'CaptureYourLife',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ],
        ),
      ),
    );
  }
}
