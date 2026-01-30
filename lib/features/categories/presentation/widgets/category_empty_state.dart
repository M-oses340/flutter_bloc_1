import 'package:flutter/material.dart';

class CategoryEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const CategoryEmptyState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No categories found."),
          TextButton(
            onPressed: onRefresh,
            child: const Text("Refresh"),
          )
        ],
      ),
    );
  }
}