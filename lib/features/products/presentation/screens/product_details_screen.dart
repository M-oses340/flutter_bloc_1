import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/repositories/product_repository.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final int shopId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.shopId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = ProductBloc(repository: ProductRepository())
      ..add(GetProductDetailsRequested(widget.productId));
  }

  @override
  void dispose() {
    _productBloc.close();
    super.dispose();
  }

  Future<void> _handleEdit(dynamic product) async {
    final success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _productBloc,
          child: EditProductScreen(product: product, shopId: widget.shopId),
        ),
      ),
    );

    if (success == true && mounted) {
      _productBloc.add(GetProductDetailsRequested(widget.productId));
    }
  }

  void _showDeleteConfirm(dynamic product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Product?"),
        content: Text("Are you sure you want to delete ${product.name}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              _productBloc.add(DeleteProductRequested(widget.productId, widget.shopId));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Product Details", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductDetailsLoaded) {
                  final product = state.product;
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _handleEdit(product);
                      } else if (value == 'delete') {
                        _showDeleteConfirm(product);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.teal),
                            SizedBox(width: 10),
                            Text("Edit Product"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductAddSuccess) {
              // Note: We check if the current state isn't a transition before popping
              // because ProductAddSuccess is used for both Edit and Delete.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Successful"), backgroundColor: Colors.teal),
              );

              // If we reach this state from a delete, we must go back to the list
              Navigator.pop(context, true);
            }
            if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) =>
            current is ProductDetailsLoaded ||
                current is ProductError ||
                current is ProductLoading,
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              if (state is ProductDetailsLoaded) {
                final product = state.product;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageHeader(product.productImage),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("SKU: ${product.sku}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const Divider(height: 40),
                            _buildDetailRow("Selling Price", "KSh ${product.sellingPrice.toStringAsFixed(0)}", isBold: true),
                            _buildDetailRow("Buying Price", "KSh ${product.buyingPrice.toStringAsFixed(0)}"),
                            _buildDetailRow("Current Stock", "${product.remainingQuantity.toInt()} units"),
                            const SizedBox(height: 40),
                            _buildStockIndicator(product.remainingQuantity),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProductError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            },
          ),
        ),
      ),
    );
  }

  // --- UI Components remain the same ---
  Widget _buildImageHeader(String url) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover)
          : const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.teal),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
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

  Widget _buildStockIndicator(double qty) {
    Color color = qty > 5 ? Colors.green : (qty > 0 ? Colors.orange : Colors.red);
    String label = qty > 5 ? "In Stock" : (qty > 0 ? "Low Stock" : "Out of Stock");

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