import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class StyleSelector extends StatelessWidget {
  final List<String> styles;
  final String selectedStyle;
  final Function(String) onStyleSelected;

  const StyleSelector({super.key, 
    required this.styles,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Style',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: styles.length,
            itemBuilder: (context, index) {
              final style = styles[index];
              final isSelected = style == selectedStyle;

              return GestureDetector(
                onTap: () => onStyleSelected(style),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getStyleIcon(style),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _capitalize(style),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getStyleIcon(String style) {
    switch (style) {
      case 'anime':
        return '🎌';
      case 'comic':
        return '💥';
      case 'hand_drawn':
        return '✏️';
      case 'watercolor':
        return '🎨';
      case 'cyberpunk':
        return '🤖';
      default:
        return '✨';
    }
  }

  String _capitalize(String str) {
    return str
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
