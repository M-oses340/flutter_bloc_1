import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/bloc/products_bloc.dart';
import '../../../products/bloc/products_event.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../bloc/category_bloc.dart';
import '../../data/models/category_model.dart';
import '../widgets/delete_category_dialog.dart';
import '../widgets/category_info_card.dart';
import '../widgets/category_product_list.dart';

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
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryInfoCard(category: category),
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
                child: CategoryProductList(
                  categoryId: category.id,
                  shopId: category.shop,
                  categoryName: category.name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
  }
}