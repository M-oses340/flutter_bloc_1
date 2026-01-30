import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/product_list_tile.dart';
import '../widgets/filter_chips_row.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart'; // Ensure this screen is created

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide a fresh instance of the Bloc for this screen
      create: (context) => ProductBloc(repository: ProductRepository())
        ..add(GetProductsRequested(widget.shopId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Products",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 28),
                onPressed: () async {
                  // Navigate to Add Product and wait for a result
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProductBloc>(),
                        child: AddProductScreen(shopId: widget.shopId),
                      ),
                    ),
                  );
                  // If product was added, refresh the list
                  if (success == true && context.mounted) {
                    context.read<ProductBloc>().add(GetProductsRequested(widget.shopId));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }

              if (state is ProductLoaded) {
                // --- SEARCH & FILTER LOGIC ---
                final filteredProducts = state.products.where((p) {
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

                return Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          FilterChipsRow(
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (val) {
                              setState(() => _selectedFilter = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? _buildNoResults()
                          : RefreshIndicator(
                        color: Colors.teal,
                        onRefresh: () async => context
                            .read<ProductBloc>()
                            .add(GetProductsRequested(widget.shopId)),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // Navigate to details screen on tap
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsScreen(
                                      productId: product.id,
                                      shopId: widget.shopId,
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh when returning to catch stock updates
                                  if (mounted) {
                                    context.read<ProductBloc>().add(
                                        GetProductsRequested(widget.shopId)
                                    );
                                  }
                                });
                              },
                              child: ProductListTile(product: product),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text("Unable to load products"));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search by name or SKU...",
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No products match your criteria",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}