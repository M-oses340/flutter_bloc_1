import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    /// The margin is calculated as:
    /// $$Margin = \frac{SellingPrice - BuyingPrice}{BuyingPrice} \times 100$$
    final double margin = product.buyingPrice > 0
        ? ((product.sellingPrice - product.buyingPrice) / product.buyingPrice) * 100
        : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ✅ FIX: Use cardColor instead of Colors.white
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(context),
              Divider(height: 32, color: theme.dividerColor),
              _buildPricingGrid(context, margin),
              _buildStockAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 55, width: 55,
            color: colorScheme.primary.withValues(alpha: 0.1),
            child: _buildProductImage(product.productImage, colorScheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: onSurface, // ✅ FIX: Dynamic text color
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "SKU: ${product.sku}",
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: onSurface.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildPricingGrid(BuildContext context, double margin) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataCell(context, "Stock", "${product.remainingQuantity.toInt()} units",
                product.remainingQuantity <= 0 ? colorScheme.error : Colors.green),
            _buildDataCell(context, "Selling", "KSh ${product.sellingPrice.toStringAsFixed(0)}", onSurface),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataCell(context, "Buying", "KSh ${product.buyingPrice.toStringAsFixed(0)}", onSurface.withValues(alpha: 0.5)),
            _buildDataCell(context, "Margin", "${margin.toStringAsFixed(1)}%", Colors.blueAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildStockAlerts() {
    if (product.remainingQuantity < 5 && product.remainingQuantity > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buildStatusBadge(Colors.orange, Icons.warning_amber_rounded, "Low Stock - Reorder Soon"),
      );
    }
    if (product.remainingQuantity <= 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buildStatusBadge(Colors.redAccent, Icons.error_outline_rounded, "Out of Stock"),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProductImage(String imageUrl, Color primaryColor) {
    if (imageUrl.isEmpty) return Icon(Icons.inventory_2_outlined, color: primaryColor, size: 28);
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
    );
  }

  Widget _buildStatusBadge(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, String label, String value, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}