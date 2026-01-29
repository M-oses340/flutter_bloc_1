import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';
import '../../bloc/category_state.dart';
import '../../data/repositories/category_repository.dart';

import 'add_category_screen.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final int shopId;

  const CategoriesScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      CategoryBloc(CategoryRepository())..add(GetCategories(shopId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Categories"),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () {
              final bloc = context.read<CategoryBloc>();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AddCategoryDialog(
                  categoryBloc: bloc,
                  shopId: shopId,
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            // Handle Errors
            if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }

            // NAVIGATION: Triggered when the single category fetch (ID 2, 7, etc.) is successful
            if (state is CategoryDetailsLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(category: state.category),
                ),
              ).then((_) {
                // Optional: Re-fetch the list when returning to ensure data is fresh
                if (context.mounted) {
                  context.read<CategoryBloc>().add(GetCategories(shopId));
                }
              });
            }
          },
          child: BlocBuilder<CategoryBloc, CategoryState>(
            // Optimization: Do not rebuild the main List UI when just loading details
            buildWhen: (previous, current) =>
            current is CategoryLoading ||
                current is CategoryLoaded ||
                current is CategoryError,
            builder: (context, state) {

              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              if (state is CategoryLoaded) {
                if (state.categories.isEmpty) return _buildEmptyState(context);

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<CategoryBloc>().add(GetCategories(shopId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () {
                            // TRIGGER: Fetch specific category (seen in your logs)
                            context.read<CategoryBloc>().add(GetCategoryDetails(cat.id));
                          },
                          leading: const Icon(Icons.category, color: Colors.teal),
                          title: Text(cat.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Shop: ${cat.shopName}"),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                );
              }

              if (state is CategoryError) {
                return _buildErrorState(context, state.message);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No categories found."),
          TextButton(
            onPressed: () => context.read<CategoryBloc>().add(GetCategories(shopId)),
            child: const Text("Refresh"),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CategoryBloc>().add(GetCategories(shopId)),
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}