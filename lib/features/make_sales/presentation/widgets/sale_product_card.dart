import 'package:flutter/material.dart';
import '../../data/models/sale_product_model.dart';


class SaleProductCard extends StatelessWidget {
  final SaleProduct product;
  final VoidCallback onAdd;

  const SaleProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = product.stock <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Section
          _buildImageThumbnail(theme),
          const SizedBox(width: 12),

          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "SKU: ${product.sku}",
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "KSh ${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStockBadge(isLowStock),
                  ],
                ),
              ],
            ),
          ),

          // Add Button
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 4),
                Text("Add"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: product.image != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(product.image!, fit: BoxFit.cover),
      )
          : Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
    );
  }

  Widget _buildStockBadge(bool isLow) {
    final color = isLow ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            product.stock.toStringAsFixed(0),
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}