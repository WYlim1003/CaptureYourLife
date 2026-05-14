import 'package:capture_your_life/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../components/image_preview.dart';
import '../components/style_selector.dart';
import '../components/primary_button.dart';
import '../components/loading_spinner.dart';
import '../providers/generation_provider.dart';
import '../services/api_service.dart';


class EditorPage extends ConsumerStatefulWidget {
  final String imagePath;

  const EditorPage({
    required this.imagePath,
    super.key,
  });

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  late String selectedTab;
  String? uploadedImageId;

  @override
  void initState() {
    super.initState();
    selectedTab = 'sticker';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uploadImage();
    });
  }

  Future<void> _uploadImage() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.uploadImage(widget.imagePath);
      if (!mounted) return; // Safer check
      setState(() {
        uploadedImageId = result['image_id'];
      });
    } catch (e) {
      if (!context.mounted) return; // Fixed BuildContext async gap warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(generationNotifierProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Generate',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ImagePreview(
                  imagePath: widget.imagePath,
                  title: 'Your Image',
                ),
                const SizedBox(height: 24),
                _TabSelector(
                  selectedTab: selectedTab,
                  onTabChanged: (tab) {
                    setState(() => selectedTab = tab);
                    ref.read(selectedStyleProvider.notifier).state = 'anime';
                  },
                ),
                const SizedBox(height: 24),
                if (selectedTab == 'avatar')
                  StyleSelector(
                    styles: const [
                      'anime',
                      'comic',
                      'hand_drawn',
                      'watercolor',
                      'cyberpunk'
                    ],
                    selectedStyle: selectedStyle,
                    onStyleSelected: (style) {
                      ref.read(selectedStyleProvider.notifier).state = style;
                    },
                  ),
                const SizedBox(height: 24),
                generationState.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return PrimaryButton(
                        label: selectedTab == 'sticker'
                            ? 'Generate Sticker'
                            : 'Generate Avatar',
                        // FIXED: The argument type error is because PrimaryButton expects a non-null VoidCallback.
                        onPressed: uploadedImageId != null
                            ? () async {
                                if (selectedTab == 'sticker') {
                                  ref
                                      .read(generationNotifierProvider.notifier)
                                      .generateSticker(uploadedImageId!);
                                } else {
                                  ref
                                      .read(generationNotifierProvider.notifier)
                                      .generateAvatar(
                                          uploadedImageId!, selectedStyle);
                                }
                                
                                // FIXED: BuildContext across async gaps warning
                                await Future.delayed(const Duration(seconds: 2));
                                if (!context.mounted) return; 

                                Navigator.pushNamed(
                                  context,
                                  '/preview',
                                  arguments: generationState,
                                );
                              }
                            : () {}, // Replaced 'null' with an empty function '() {}'
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const LoadingSpinner(
                    message: 'Generating your creation...',
                  ),
                  error: (error, stack) => Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error: $error',
                        style: const TextStyle(color: AppColors.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Retry',
                        onPressed: () {
                          ref.read(generationNotifierProvider.notifier).reset();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  // FIXED: Removed "super.key" to resolve the "value for optional parameter 'key' isn't ever given" warning.
  const _TabSelector({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'Sticker',
          isSelected: selectedTab == 'sticker',
          onPressed: () => onTabChanged('sticker'),
        ),
        const SizedBox(width: 12),
        _TabButton(
          label: 'Avatar',
          isSelected: selectedTab == 'avatar',
          onPressed: () => onTabChanged('avatar'),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  // FIXED: Removed "super.key" here as well.
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}