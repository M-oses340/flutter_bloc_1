import 'package:flutter/material.dart';

class ProductDetailsHeader extends StatelessWidget {
  final String imageUrl;

  const ProductDetailsHeader({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl, fit: BoxFit.cover)
          : const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.teal),
    );
  }
}