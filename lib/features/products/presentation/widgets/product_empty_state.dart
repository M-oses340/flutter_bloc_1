import 'package:flutter/material.dart';

class ProductEmptyState extends StatelessWidget {
  final String message;

  const ProductEmptyState({
    super.key,
    this.message = "No products match your criteria",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use onSurfaceVariant for a consistent "muted" look across themes
    final mutedColor = colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ FIX: Use a subtle opacity of the theme color instead of hardcoded grey
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: mutedColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or search terms",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: mutedColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}