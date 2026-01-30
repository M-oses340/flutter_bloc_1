import 'package:flutter/material.dart';

class ProductStockBadge extends StatelessWidget {
  final double quantity;

  const ProductStockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color color = quantity > 5 ? Colors.green : (quantity > 0 ? Colors.orange : Colors.red);
    String label = quantity > 5 ? "In Stock" : (quantity > 0 ? "Low Stock" : "Out of Stock");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}