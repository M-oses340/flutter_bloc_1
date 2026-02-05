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

  Widget _buildSearchBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) => context.read<StoreBloc>().add(SearchStoreStocks(query)),
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<StoreBloc>().add(SearchStoreStocks(''));
                  setState(() {});
                })
                : null,
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), // Stadium look
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Store Inventory", style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
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
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: colorScheme.primary, size: 24),
                ),
              ),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.primaryContainer.withValues(alpha: 0.1),
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(theme),

                // Refined Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 0,
                          selectedColor: colorScheme.primary,
                          backgroundColor: theme.cardColor,
                          shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.1))),
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: BlocBuilder<StoreBloc, StoreState>(
                    builder: (context, state) {
                      if (state is StoreLoading) return const Center(child: CircularProgressIndicator());
                      if (state is StoreLoaded) {
                        if (state.stocks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text("No products found", style: TextStyle(color: theme.hintColor)),
                              ],
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async => context.read<StoreBloc>().add(RefreshStoreStocks()),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: state.stocks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}