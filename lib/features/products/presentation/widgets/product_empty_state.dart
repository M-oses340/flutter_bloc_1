import 'package:flutter/material.dart';

class ProductEmptyState extends StatelessWidget {
  final String message;

  const ProductEmptyState({
    super.key,
    this.message = "No products match your criteria",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No products match your criteria",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}