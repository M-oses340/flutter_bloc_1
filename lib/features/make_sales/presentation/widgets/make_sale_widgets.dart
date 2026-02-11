import 'package:flutter/material.dart';

/// The top section: Search bar + Scan button
class SaleSearchHeader extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onScanTap;

  const SaleSearchHeader({
    super.key,
    required this.onSearch,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            hintText: "Search by name or SKU...",
            onChanged: onSearch,
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(theme.cardColor),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
            leading: const Icon(Icons.search, color: Colors.grey),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onScanTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 54, width: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // Uses primaryTeal from your AppTheme
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
          ),
        )
      ],
    );
  }
}

/// The bottom summary bar: Items count + Total price
class SaleCartSummary extends StatelessWidget {
  final int itemCount;
  final double totalAmount;
  final VoidCallback onCheckout;

  const SaleCartSummary({
    super.key,
    required this.itemCount,
    required this.totalAmount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Hide if cart is empty
    if (itemCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // Adaptive background for Light/Dark mode
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10, offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$itemCount items", style: theme.textTheme.bodyMedium),
                Text(
                  "KSh ${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary, // Matches primaryTeal
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              label: const Text("View Cart"),
            ),
          ],
        ),
      ),
    );
  }
}