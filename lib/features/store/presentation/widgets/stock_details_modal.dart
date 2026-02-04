import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 1. Add this import
import '../../bloc/store_bloc.dart';            // 2. Add your bloc import
import '../../data/models/store_stock.dart';
import 'stock_details_content.dart';

/// Logic function to trigger the Bottom Sheet
void showStockDetailsModal(BuildContext context, StoreStock stock) {
  // 3. Capture the existing Bloc instance from the screen context
  final storeBloc = context.read<StoreBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => BlocProvider.value(
      value: storeBloc, // 4. Provide the existing instance to the modal
      child: StockDetailsContent(stock: stock),
    ),
  );
}