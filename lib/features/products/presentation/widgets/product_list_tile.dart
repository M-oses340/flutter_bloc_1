import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap; // Add this

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap, // Add this
  });

  @override
  Widget build(BuildContext context) {
    /// The margin is calculated as:
    /// $$Margin = \frac{SellingPrice - BuyingPrice}{BuyingPrice} \times 100$$
    final double margin = product.buyingPrice > 0
        ? ((product.sellingPrice - product.buyingPrice) / product.buyingPrice) * 100
        : 0.0;

    return Material( // Added Material for InkWell splash effects
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // Apply the callback here
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const Divider(height: 32),
              _buildPricingGrid(margin),
              _buildStockAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Extracted UI Helper Methods for better readability ---

  Widget _buildTopRow() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 55, width: 55,
            color: Colors.teal.withValues(alpha: 0.05),
            child: _buildProductImage(product.productImage),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text("SKU: ${product.sku}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey), // Changed to chevron for "navigation" feel
      ],
    );
  }

  Widget _buildPricingGrid(double margin) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataCell("Stock", "${product.remainingQuantity.toInt()} units",
                product.remainingQuantity <= 0 ? Colors.red : Colors.green),
            _buildDataCell("Selling", "KSh ${product.sellingPrice.toStringAsFixed(0)}", Colors.black),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataCell("Buying", "KSh ${product.buyingPrice.toStringAsFixed(0)}", Colors.grey),
            _buildDataCell("Margin", "${margin.toStringAsFixed(1)}%", Colors.blue),
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
        child: _buildStatusBadge(Colors.red, Icons.error_outline_rounded, "Out of Stock"),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) return const Icon(Icons.inventory_2_outlined, color: Colors.teal, size: 28);
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

  Widget _buildDataCell(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}