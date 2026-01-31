import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/bloc/products_bloc.dart';
import '../../../products/bloc/products_event.dart';
import '../../../products/bloc/products_state.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../products/presentation/widgets/product_list_tile.dart';

class CategoryProductList extends StatelessWidget {
  final int categoryId;
  final int shopId;
  final String categoryName;

  const CategoryProductList({
    super.key,
    required this.categoryId,
    required this.shopId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          // ✅ FIX: Use primary brand color
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return _buildEmptyProducts(context);
          }

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () async {
              context.read<ProductBloc>().add(FilterByCategoryRequested(
                categoryId: categoryId,
                shopId: shopId,
              ));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ProductListTile(
                  product: product,
                  onTap: () => _navigateToDetails(context, product.id),
                );
              },
            ),
          );
        }

        if (state is ProductError) {
          return Center(
            child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error) // ✅ FIX: Use semantic error
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToDetails(BuildContext context, int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: productId,
          shopId: shopId,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<ProductBloc>().add(FilterByCategoryRequested(
          categoryId: categoryId,
          shopId: shopId,
        ));
      }
    });
  }

  Widget _buildEmptyProducts(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ FIX: Themed icon color
          Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
          ),
          const SizedBox(height: 12),
          Text(
            "No products assigned to $categoryName",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}