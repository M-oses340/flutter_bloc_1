import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/bloc/products_bloc.dart';
import '../../../products/bloc/products_event.dart';
import '../../../products/bloc/products_state.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../products/presentation/widgets/product_list_tile.dart';
import '../../bloc/category_bloc.dart';
import '../../data/models/category_model.dart';
import '../widgets/delete_category_dialog.dart';


class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => DeleteCategoryDialog(
                  categoryId: category.id,
                  shopId: category.shop,
                  categoryName: category.name,
                  categoryBloc: context.read<CategoryBloc>(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text(
              "Products in this category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocProvider(
                create: (context) => ProductBloc(repository: ProductRepository())
                  ..add(FilterByCategoryRequested(
                    categoryId: category.id,
                    shopId: category.shop,
                  )),
                child: BlocBuilder<ProductBloc, ProductState>(
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
                          // Trigger the filter event again to refresh the list
                          context.read<ProductBloc>().add(FilterByCategoryRequested(
                            categoryId: category.id,
                            shopId: category.shop,
                          ));
                        },
                        child: ListView.builder(
                          // AlwaysScrollableScrollPhysics ensures pull-to-refresh works even with few items
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
                                      shopId: category.shop,
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
                          child: Text(state.message, style: const TextStyle(color: Colors.red))
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _detailRow("Category ID", category.id.toString()),
          const Divider(),
          _detailRow("Shop Name", category.shopName),
          const Divider(),
          _detailRow("Status", category.isActive ? "Active" : "Inactive",
              valueColor: category.isActive ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text("No products assigned to ${category.name}",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}