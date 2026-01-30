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
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return _buildEmptyProducts();
          }

          return RefreshIndicator(
            color: Colors.teal,
            onRefresh: () async {
              context.read<ProductBloc>().add(FilterByCategoryRequested(
                categoryId: categoryId,
                shopId: shopId,
              ));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          productId: product.id,
                          shopId: shopId,
                        ),
                      ),
                    );
                  },
                  child: ProductListTile(product: product),
                );
              },
            ),
          );
        }

        if (state is ProductError) {
          return Center(
            child: Text(state.message, style: const TextStyle(color: Colors.red)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text("No products assigned to $categoryName",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}