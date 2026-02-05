import 'package:flutter/material.dart';
import '../../data/models/store_stock.dart';

class TransferProductHeader extends StatelessWidget {
  final StoreStock stock;
  const TransferProductHeader({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "SKU: ${stock.productSku}",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(Icons.store, stock.shopName, colorScheme.secondary),
                    const SizedBox(width: 8),
                    _Badge(Icons.payments, "KSh ${stock.buyingPrice}", Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransferSummaryCard extends StatelessWidget {
  final double quantity;
  final double remaining;
  final double totalValue;

  const TransferSummaryCard({
    super.key,
    required this.quantity,
    required this.remaining,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _summaryRow(theme, "Transferring", "${quantity.toStringAsFixed(2)} units"),
          // Inside TransferSummaryCard build method:
          _summaryRow(
            theme,
            "Remaining",
            "${remaining.toStringAsFixed(2)} units",
            // 💡 Highlight red if stock hits zero or becomes negative
            valueColor: remaining <= 0 ? theme.colorScheme.error : null,
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Value", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              Text(
                "KSh ${totalValue.toStringAsFixed(2)}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Switched from hardcoded teal to primary
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.bodyMedium?.color, // Use custom color if provided
          )),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}