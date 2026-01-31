import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';
import '../../bloc/category_state.dart';
import '../../data/repositories/category_repository.dart';
import 'category_detail_screen.dart';
import '../widgets/category_list_tile.dart';
import '../widgets/category_empty_state.dart';
import '../widgets/category_error_state.dart';
import '../widgets/category_add_button.dart';

class CategoriesScreen extends StatelessWidget {
  final int shopId;
  const CategoriesScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => CategoryBloc(CategoryRepository())..add(GetCategories(shopId)),
      child: Scaffold(
        // ✅ FIX: Use theme scaffold background instead of hardcoded hex
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          // ✅ FIX: Inherit AppBar theme for automatic light/dark switching
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 0,
        ),
        floatingActionButton: CategoryAddButton(shopId: shopId),
        body: BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryDetailsLoaded) {
              final categoryBloc = context.read<CategoryBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: categoryBloc,
                    child: CategoryDetailScreen(category: state.category),
                  ),
                ),
              ).then((_) {
                if (context.mounted) categoryBloc.add(GetCategories(shopId));
              });
            }
          },
          child: BlocBuilder<CategoryBloc, CategoryState>(
            buildWhen: (p, c) => c is CategoryLoading || c is CategoryLoaded || c is CategoryError,
            builder: (context, state) {
              if (state is CategoryLoading) {
                // ✅ FIX: Use theme primary (Teal)
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
              }

              if (state is CategoryLoaded) {
                if (state.categories.isEmpty) {
                  return CategoryEmptyState(
                    onRefresh: () => context.read<CategoryBloc>().add(GetCategories(shopId)),
                  );
                }

                return RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: () async => context.read<CategoryBloc>().add(GetCategories(shopId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      return CategoryListTile(
                        category: state.categories[index],
                        onTap: () => context.read<CategoryBloc>().add(GetCategoryDetails(state.categories[index].id)),
                      );
                    },
                  ),
                );
              }

              if (state is CategoryError) {
                return CategoryErrorState(
                  message: state.message,
                  onRetry: () => context.read<CategoryBloc>().add(GetCategories(shopId)),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}