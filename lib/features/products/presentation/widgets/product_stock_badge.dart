import 'package:flutter/material.dart';

class ProductStockBadge extends StatelessWidget {
  final double quantity;

  const ProductStockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define colors based on theme for better harmony
    Color badgeColor;
    String label;

    if (quantity > 5) {
      // Accessible green (adjusts slightly for dark mode)
      badgeColor = Colors.greenAccent[700] ?? Colors.green;
      label = "In Stock";
    } else if (quantity > 0) {
      badgeColor = Colors.orangeAccent[700] ?? Colors.orange;
      label = "Low Stock";
    } else {
      // ✅ Use theme-defined error color for consistency
      badgeColor = colorScheme.error;
      label = "Out of Stock";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Soft background tint that works in both modes
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        // Subtle border helps definition in Dark Mode
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: badgeColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}