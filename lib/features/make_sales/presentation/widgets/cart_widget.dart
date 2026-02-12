import 'package:flutter/material.dart';
import '../../data/models/sale_product_model.dart';

class CartItemTile extends StatelessWidget {
  final SaleProduct item;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Top Section: Image, Info, and Remove Button
            Row(
              children: [
                _buildImage(),
                const SizedBox(width: 12),
                Expanded(child: _buildInfo(theme)),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            // Bottom Section: Quantity Controls and Subtotal
            _buildQuantityRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        image: item.image != null
            ? DecorationImage(image: NetworkImage(item.image!), fit: BoxFit.cover)
            : null,
      ),
      child: item.image == null
          ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        Text(
            "SKU: ${item.sku}",
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "KSh ${item.price}",
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13
                  )
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 12, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Quantity Controls
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove)
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                    "$quantity",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              IconButton(
                  onPressed: onIncrement,
                  icon: Icon(Icons.add, color: theme.colorScheme.primary)
              ),
            ],
          ),
        ),
        // Item Subtotal (Price * Quantity)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Total", style: theme.textTheme.bodySmall),
            Text(
              "KSh ${(item.price * quantity).toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 18
              ),
            ),
          ],
        )
      ],
    );
  }
}