import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/sale_product_model.dart';


class SaleProductCard extends StatelessWidget {
  final SaleProduct product;
  final VoidCallback onAdd;

  const SaleProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  String? get _fullImageUrl {
    if (product.image == null || product.image!.isEmpty) return null;
    if (product.image!.startsWith('http')) return product.image;

    String base = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;

    return "$base${product.image}";
  }

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
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Fixed Image Section
          _buildProductImage(theme),
          const SizedBox(width: 12),

          // 2. Flexible Details Section (Prevents overall Row overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "SKU: ${product.sku}",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Price and Stock Row
                Row(
                  children: [
                    // Expanded here prevents the price from pushing the badge off-screen
                    Expanded(
                      child: Text(
                        "KSh ${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Slightly reduced for better fit
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildStockBadge(isLowStock),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Action Button
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 2),
                Text("Add", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    final imageUrl = _fullImageUrl;
    return Container(
      width: 65, // Slightly smaller to give text more room
      height: 65,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(theme),
        ),
      )
          : _buildPlaceholderIcon(theme),
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 28);
  }

  Widget _buildStockBadge(bool isLow) {
    final color = isLow ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            product.stock.toStringAsFixed(1), // Fixed to 1 decimal to save space
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}