import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductListScreen extends StatefulWidget {
  final int shopId;

  const ProductListScreen({super.key, required this.shopId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(
        repository: ProductRepository(),
      )..add(GetProductsRequested(widget.shopId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "Products",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: () {}, // Logic for top-right add button
              icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
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
                  // 1. Fixed Header Section (Search & Filter)
                  _buildHeaderActions(),

                  // 2. Scrollable List Section
                  Expanded(
                    child: state.products.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                      onRefresh: () async => context
                          .read<ProductBloc>()
                          .add(GetProductsRequested(widget.shopId)),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return _ProductListTile(product: product);
                        },
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is ProductError) {
              return _buildErrorState(context, state.message);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or SKU...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
          ),
          // Scrollable Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("In Stock"),
                _buildFilterChip("Low Stock"),
                _buildFilterChip("Out of Stock"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00695C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No products found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
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
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => context
                  .read<ProductBloc>()
                  .add(GetProductsRequested(widget.shopId)),
              child: const Text("Try Again", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final Product product;
  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    // Profit Margin Calculation
    final double margin = product.buyingPrice > 0
        ? ((product.sellingPrice - product.buyingPrice) / product.buyingPrice) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("SKU: ${product.sku}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDataCell("Stock", "${product.remainingQuantity.toInt()} units", Colors.green),
              _buildDataCell("Selling", "KSh ${product.sellingPrice.toStringAsFixed(0)}", Colors.black),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDataCell("Buying", "KSh ${product.buyingPrice.toStringAsFixed(0)}", Colors.grey),
              _buildDataCell("Margin", "${margin.toStringAsFixed(1)}%", Colors.blue),
            ],
          ),
          // Low Stock Badge (Only shows if quantity < 5)
          if (product.remainingQuantity < 5) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text("Low Stock - Reorder Soon",
                      style: TextStyle(
                          color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDataCell(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}