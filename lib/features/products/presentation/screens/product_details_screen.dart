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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // AlertDialog background automatically follows theme.dialogBackgroundColor
        title: const Text("Delete Product?"),
        content: Text("Are you sure you want to delete ${product.name}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _productBloc.add(DeleteProductRequested(widget.productId, widget.shopId));
            },
            child: Text("Delete", style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        // ✅ FIX: Use theme-based scaffold background
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Product Details"),
          actions: [_buildPopupMenu(colorScheme)],
        ),
        body: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductAddSuccess) {
              Navigator.pop(context, true);
            }
            if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (p, c) => c is ProductDetailsLoaded || c is ProductLoading || c is ProductError,
            builder: (context, state) {
              if (state is ProductLoading) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
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
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: colorScheme.error),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(ColorScheme colorScheme) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductDetailsLoaded) return const SizedBox();
        final product = state.product;
        return PopupMenuButton<String>(
          onSelected: (val) => val == 'edit' ? _handleEdit(product) : _showDeleteConfirm(product),
          itemBuilder: (context) => [
            PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 8),
                    const Text("Edit Product"),
                  ],
                )
            ),
            PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Text("Delete", style: TextStyle(color: colorScheme.error)),
                  ],
                )
            ),
          ],
        );
      },
    );
  }
}