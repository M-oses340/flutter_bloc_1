import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';
import '../../bloc/category_state.dart';
import '../../data/repositories/category_repository.dart';

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
        // Use Builder to provide a context that is UNDER the BlocProvider
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () => _showAddCategoryDialog(context),
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
                return const Center(
                    child: CircularProgressIndicator(color: Colors.teal));
              }

              if (state is CategoryLoaded) {
                if (state.categories.isEmpty) {
                  return _buildEmptyState(context);
                }
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
                          leading:
                          const Icon(Icons.category, color: Colors.teal),
                          title: Text(cat.name,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
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

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("New Category"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter category name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                // Accessing the Bloc from the original context passed to this function
                context.read<CategoryBloc>().add(
                  AddCategoryRequested(name: name, shopId: shopId),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
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
          const Text("No categories found for this shop."),
          TextButton(
            onPressed: () =>
                context.read<CategoryBloc>().add(GetCategories(shopId)),
            child: const Text("Refresh"),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              onPressed: () =>
                  context.read<CategoryBloc>().add(GetCategories(shopId)),
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}