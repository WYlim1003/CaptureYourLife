import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_colors.dart';
import 'pages/home_page.dart';
import 'pages/camera_page.dart';
import 'pages/editor_page.dart';
import 'pages/preview_page.dart';
import 'pages/gallery_page.dart';
import 'providers/generation_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaptureYourLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          labelLarge: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/camera':
            return MaterialPageRoute(builder: (_) => const CameraPage());
          case '/editor':
            final imagePath = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => EditorPage(imagePath: imagePath),
            );
          case '/preview':
            final generationResult = settings.arguments as AsyncValue<Map<String, dynamic>>;
            return MaterialPageRoute(
              builder: (_) => PreviewPage(generationResult: generationResult),
            );
          case '/gallery':
            return MaterialPageRoute(builder: (_) => const GalleryPage());
          default:
            return MaterialPageRoute(builder: (_) => const HomePage());
        }
      },
      home: const HomePage(),
    );
  }
}
