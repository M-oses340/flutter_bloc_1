import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/product_list_tile.dart';
import '../widgets/filter_chips_row.dart';
import '../screens/add_product_screen.dart';

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
  Widget build(BuildContext context) {
    return BlocProvider(
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
          iconTheme: const IconThemeData(color: Colors.black),
          // 1. FAB logic moved to AppBar Actions
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 28),
                onPressed: () async {
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProductBloc>(),
                        child: AddProductScreen(shopId: widget.shopId),
                      ),
                    ),
                  );
                  // Refresh list if a product was added
                  if (success == true && context.mounted) {
                    context.read<ProductBloc>().add(GetProductsRequested(widget.shopId));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }

            if (state is ProductLoaded) {
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
                          onFilterSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => context
                          .read<ProductBloc>()
                          .add(GetProductsRequested(widget.shopId)),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) =>
                            ProductListTile(product: state.products[index]),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // 2. FAB property removed to match your reference image
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}