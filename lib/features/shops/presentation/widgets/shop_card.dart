import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/shop_model.dart';
import '../screens/shop_dashboard_screen.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Material 3 prefers tonal elevation over heavy shadows
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      // ✅ FIX: Use surfaceContainerLow or cardColor for better dark mode depth
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'shop-icon-${shop.id}',
          child: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              shop.name[0].toUpperCase(),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          shop.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${shop.location ?? 'Unknown location'}\nRole: ${shop.userRole}",
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        isThreeLine: true,
        trailing: Icon(
          Icons.chevron_right,
          // ✅ FIX: Use theme colors for status
          color: shop.isActive ? Colors.greenAccent[700] : colorScheme.outline,
        ),
        onTap: () async {
          // Store shopId in background
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt("shopId", shop.id);
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDashboardScreen(shop: shop),
            ),
          );
        },
      ),
    );
  }
}