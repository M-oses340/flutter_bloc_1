import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(shop.name),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Status Chip using Theme colors
            Chip(
              side: BorderSide.none,
              label: Text(
                shop.isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color: shop.isActive ? Colors.green[800] : colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: shop.isActive
                  ? Colors.green.withValues(alpha: 0.2)
                  : colorScheme.errorContainer.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),

            // ✅ Info Sections
            _infoTile(context, Icons.person_outline, "Owner", shop.ownerName),
            _infoTile(context, Icons.location_on_outlined, "Location", shop.location ?? "No location provided"),
            _infoTile(context, Icons.badge_outlined, "Your Role", shop.userRole),

            const Divider(height: 40),

            Text(
                "Description",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
              shop.description ?? "No description available for this shop.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          )
      ),
      subtitle: Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          )
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}