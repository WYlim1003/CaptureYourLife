import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/main_page.dart';
import 'pages/camera_page.dart';
import 'pages/gallery_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/photo_detail_page.dart';
import 'pages/editor_page.dart';
import 'pages/preview_page.dart';
import 'pages/splash_page.dart';
import 'pages/email_verification_page.dart';
import 'pages/theme_picker_page.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeDataProvider);

    return MaterialApp(
      title: 'CaptureYourLife',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return _fadeRoute(const MainPage());
          case '/camera':
            final args = settings.arguments;
            final autoOpen = args is Map && args['autoOpenCamera'] == true;
            return _fadeRoute(CameraPage(autoOpenCamera: autoOpen));
          case '/gallery':
            return _fadeRoute(const GalleryPage());
          case '/login':
            return _fadeRoute(const LoginPage());
          case '/register':
            return _fadeRoute(const RegisterPage());
          case '/email_verify':
            return _fadeRoute(const EmailVerificationPage());
          case '/theme_picker':
            return _fadeRoute(const ThemePickerPage());
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
            return _fadeRoute(const SplashPage());
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
