import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/product_details_header.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_stock_badge.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final int shopId;

  const ProductDetailsScreen({super.key, required this.productId, required this.shopId});

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

  // --- LOGIC METHODS (Fixes the "not defined" errors) ---

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

    // Refresh the details if the product was updated
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

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Product Details"),
          actions: [_buildPopupMenu()],
        ),
        body: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductAddSuccess) {
              // Usually indicates a successful deletion or update that requires closing the screen
              Navigator.pop(context, true);
            }
            if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (p, c) => c is ProductDetailsLoaded || c is ProductLoading || c is ProductError,
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              if (state is ProductDetailsLoaded) {
                final p = state.product;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ProductDetailsHeader(imageUrl: p.productImage),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            ProductInfoSection(product: p),
                            const SizedBox(height: 40),
                            ProductStockBadge(quantity: p.remainingQuantity),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProductError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductDetailsLoaded) return const SizedBox();
        final product = state.product;
        return PopupMenuButton<String>(
          onSelected: (val) => val == 'edit' ? _handleEdit(product) : _showDeleteConfirm(product),
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text("Edit Product"),
                  ],
                )
            ),
            const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete", style: TextStyle(color: Colors.red)),
                  ],
                )
            ),
          ],
        );
      },
    );
  }
}