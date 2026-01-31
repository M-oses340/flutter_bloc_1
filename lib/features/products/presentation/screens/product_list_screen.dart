import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/product_list_tile.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_empty_state.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int shopId;
  const ProductListScreen({super.key, required this.shopId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List _getFilteredProducts(List products) {
    return products.where((p) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query);

      if (_selectedFilter == "Low Stock") {
        return matchesSearch && p.remainingQuantity > 0 && p.remainingQuantity < 5;
      }
      if (_selectedFilter == "Out of Stock") {
        return matchesSearch && p.remainingQuantity <= 0;
      }
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => ProductBloc(repository: ProductRepository())
        ..add(GetProductsRequested(widget.shopId)),
      child: Scaffold(
        // ✅ Use theme-based scaffold background
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(child: CircularProgressIndicator(color: colorScheme.primary));
            }

            if (state is ProductLoaded) {
              final filteredProducts = _getFilteredProducts(state.products);

              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const ProductEmptyState()
                        : _buildProductList(filteredProducts, colorScheme.primary),
                  ),
                ],
              );
            }
            return Center(
              child: Text(
                "Unable to load products",
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        "Products",
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary, size: 28),
            onPressed: () => _navigateToAddProduct(context),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // ✅ Use cardColor or surface so it turns dark in dark mode
      color: theme.cardColor,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ProductSearchBar(
            controller: _searchController,
            onChanged: () => setState(() {}),
          ),
          FilterChipsRow(
            selectedFilter: _selectedFilter,
            onFilterSelected: (val) => setState(() => _selectedFilter = val),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List filteredProducts, Color primaryColor) {
    return Builder(
      builder: (context) => RefreshIndicator(
        color: primaryColor,
        onRefresh: () async => context.read<ProductBloc>().add(GetProductsRequested(widget.shopId)),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ProductListTile(
              product: product,
              onTap: () => _navigateToDetails(context, product.id),
            );
          },
        ),
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) async {
    final productBloc = context.read<ProductBloc>();

    final success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: productBloc,
          child: AddProductScreen(shopId: widget.shopId),
        ),
      ),
    );

    if (success == true && mounted) {
      productBloc.add(GetProductsRequested(widget.shopId));
    }
  }

  void _navigateToDetails(BuildContext context, int productId) async {
    final productBloc = context.read<ProductBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: productId,
          shopId: widget.shopId,
        ),
      ),
    );

    if (mounted) {
      productBloc.add(GetProductsRequested(widget.shopId));
    }
  }
}