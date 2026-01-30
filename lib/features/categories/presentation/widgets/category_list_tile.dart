import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.category, color: Colors.teal),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Shop: ${category.shopName}"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}