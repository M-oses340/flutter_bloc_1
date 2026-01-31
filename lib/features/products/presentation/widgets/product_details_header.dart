import 'package:flutter/material.dart';

class ProductDetailsHeader extends StatelessWidget {
  final String imageUrl;

  const ProductDetailsHeader({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        // ✅ FIX: Uses a tonal surface color that adapts to dark/light mode
        color: colorScheme.surfaceContainerLow,
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // Handles loading state smoothly
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        // Handles broken links
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image_outlined,
          size: 80,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      )
          : Icon(
        Icons.inventory_2_outlined,
        size: 80,
        // ✅ Uses the brand primary color (Teal) from theme
        color: colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}