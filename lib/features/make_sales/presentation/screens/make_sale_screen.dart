import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/make_sale_bloc.dart';
import '../../bloc/make_sale_event.dart';
import '../../bloc/make_sale_state.dart';

import '../widgets/sale_product_card.dart';

class MakeSaleScreen extends StatelessWidget {
  final int shopId;

  const MakeSaleScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Pulling the background color from your AppTheme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Make Sale"),
        // The theme handles centerTitle and elevation automatically
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildSearchAndScan(context),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MakeSaleBloc, MakeSaleState>(
                builder: (context, state) {
                  if (state is MakeSaleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MakeSaleLoaded) {
                    return ListView.builder(
                      itemCount: state.filteredProducts.length,
                      itemBuilder: (context, index) {
                        return SaleProductCard(
                          product: state.filteredProducts[index],
                          onAdd: () {
                            // Logic for Cart will go here
                          },
                        );
                      },
                    );
                  } else if (state is MakeSaleError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndScan(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: SearchBar(
            hintText: "Search products...",
            onChanged: (value) {
              context.read<MakeSaleBloc>().add(SearchSaleProducts(value));
            },
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(theme.cardColor),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
            leading: const Icon(Icons.search, color: Colors.grey),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Scanner Button using your primaryTeal
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
      ],
    );
  }
}