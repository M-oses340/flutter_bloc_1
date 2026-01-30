import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("SKU: ${product.sku}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const Divider(height: 40),
        _DetailRow(label: "Selling Price", value: "KSh ${product.sellingPrice.toStringAsFixed(0)}", isBold: true),
        _DetailRow(label: "Buying Price", value: "KSh ${product.buyingPrice.toStringAsFixed(0)}"),
        _DetailRow(label: "Current Stock", value: "${product.remainingQuantity.toInt()} units"),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? Colors.teal : Colors.black
          )),
        ],
      ),
    );
  }
}