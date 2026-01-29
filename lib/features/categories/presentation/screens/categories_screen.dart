import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';
import '../../bloc/category_state.dart';
import '../../data/repositories/category_repository.dart';
import 'add_category_screen.dart'; // Import the new dialog file

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
              // 1. Capture the bloc from the current context
              final bloc = context.read<CategoryBloc>();

              // 2. Open the separate dialog file as a popup
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent closing by tapping outside while saving
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
            if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<CategoryBloc, CategoryState>(
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.category, color: Colors.teal),
                          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Shop: ${cat.shopName}"),
                          trailing: Icon(
                            Icons.circle,
                            color: cat.isActive ? Colors.green : Colors.red,
                            size: 10,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return _buildErrorState(context, "Something went wrong");
            },
          ),
        ),
      ),
    );
  }

  // ... (Keep your _buildEmptyState and _buildErrorState the same)
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () => context.read<CategoryBloc>().add(GetCategories(shopId)),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}