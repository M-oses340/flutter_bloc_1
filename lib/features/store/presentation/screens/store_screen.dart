import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/store_bloc.dart';
import '../../bloc/store_event.dart';
import '../../bloc/store_state.dart';
import '../widgets/stock_product_card.dart';
import 'add_product_to_store.dart';


class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Define the search bar helper here to keep build() clean
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) => context.read<StoreBloc>().add(SearchStoreStocks(query)),
        decoration: InputDecoration(
          hintText: "Search by name or SKU...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<StoreBloc>().add(SearchStoreStocks(''));
                setState(() {}); // Updates UI to hide clear icon
              })
              : null,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Store Products", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () {
                  // ✅ Navigating to Add screen using shared Bloc
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<StoreBloc>(),
                        child: const AddProductToStoreScreen(),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 28)
            )
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(theme),

            // Filter Chips Section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => selectedFilter = filter);
                        context.read<StoreBloc>().add(FilterStoreStocks(filter));
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                          fontSize: 12
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: BlocBuilder<StoreBloc, StoreState>(
                builder: (context, state) {
                  if (state is StoreLoading) return const Center(child: CircularProgressIndicator());
                  if (state is StoreLoaded) {
                    if (state.stocks.isEmpty) {
                      return const Center(child: Text("No products found."));
                    }
                    return RefreshIndicator(
                      onRefresh: () async => context.read<StoreBloc>().add(RefreshStoreStocks()),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.stocks.length,
                        itemBuilder: (context, index) => StockProductCard(stock: state.stocks[index]),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}