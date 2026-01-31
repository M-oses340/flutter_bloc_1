import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryInfoCard extends StatelessWidget {
  final Category category;

  const CategoryInfoCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIX: SurfaceContainerLow provides a modern M3 "card" look
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _detailRow(context, "Category ID", category.id.toString()),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          _detailRow(context, "Shop Name", category.shopName),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          _detailRow(
            context,
            "Status",
            category.isActive ? "Active" : "Inactive",
            // ✅ FIX: Use semantic colors instead of hardcoded Green/Red
            valueColor: category.isActive ? colorScheme.primary : colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant, // Muted label color
              )
          ),
          Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? colorScheme.onSurface, // Adaptive primary text
              )
          ),
        ],
      ),
    );
  }
}