import 'package:flutter/material.dart';
import '../../data/models/store_stock.dart';

class StockProductCard extends StatelessWidget {
  final StoreStock stock;
  const StockProductCard({super.key, required this.stock});

  double get margin {
    if (stock.buyingPrice <= 0) return 0.0;
    return ((stock.sellingPrice - stock.buyingPrice) / stock.buyingPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ✅ Replaced withOpacity with withValues
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.productName,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "SKU: ${stock.productSku}",
                      style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: theme.hintColor),
            ],
          ),
          Divider(height: 32, color: theme.dividerColor),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 10,
            ),
            children: [
              _infoTile(context, Icons.shopping_cart_outlined, "Stock", "${stock.remainingQuantity} units", colorScheme.primary),
              _infoTile(context, Icons.attach_money, "Selling", "KSh ${stock.sellingPrice}", textTheme.bodyLarge?.color ?? Colors.black),
              _infoTile(context, Icons.shopping_bag_outlined, "Buying", "KSh ${stock.buyingPrice}", theme.hintColor),
              _infoTile(context, Icons.trending_up, "Margin", "${margin.toStringAsFixed(1)}%", colorScheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value, Color valColor) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.hintColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valColor,
              ),
            ),
          ],
        )
      ],
    );
  }
}