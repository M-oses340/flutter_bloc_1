import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryInfoCard extends StatelessWidget {
  final Category category;

  const CategoryInfoCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _detailRow("Category ID", category.id.toString()),
          const Divider(),
          _detailRow("Shop Name", category.shopName),
          const Divider(),
          _detailRow("Status", category.isActive ? "Active" : "Inactive",
              valueColor: category.isActive ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }
}