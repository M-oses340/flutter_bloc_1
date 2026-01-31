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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // ✅ FIX: Use theme-defined colors for automatic switching
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            // ✅ FIX: Use semantic error color for delete actions
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryInfoCard(category: category),
            const SizedBox(height: 32), // Increased spacing for better hierarchy
            Text(
              "Products in this category",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
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