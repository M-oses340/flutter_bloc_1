import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/store_stock.dart';
import '../data/repositories/store_repository.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository repository;

  List<StoreStock> _allStocks = [];
  String _currentSearch = '';
  String _currentFilter = 'All';

  StoreBloc({required this.repository}) : super(StoreInitial()) {
    on<LoadStoreStocks>((event, emit) async {
      emit(StoreLoading());
      try {
        _allStocks = await repository.fetchStoreStocks();
        emit(StoreLoaded(_allStocks));
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });

    on<RefreshStoreStocks>((event, emit) async {
      try {
        _allStocks = await repository.fetchStoreStocks();
        _applyFilters(emit);
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });

    on<TransferStockEvent>((event, emit) async {

      try {
        emit(StoreLoading());


        bool exists = await repository.checkProductExists(event.stock.product);

        if (!exists) {
          debugPrint("Restoring product template for: ${event.stock.productName}");
          await repository.restoreProduct(event.stock);
        }


        await repository.transferStockToMain(event.stock.id, event.quantity);


        emit(StoreTransferSuccess(message: "Transferred ${event.quantity} units to main stock."));


        _allStocks = await repository.fetchStoreStocks();
        _applyFilters(emit);

      } catch (e) {

        emit(StoreError(e.toString()));
      }
    });

    on<AddStoreStockEvent>((event, emit) async {
      try {
        Map<String, dynamic> stockData = Map.from(event.stockData);
        final shopId = stockData['shop'];
        if (stockData['product'] is String) {
          final String productName = stockData['product'].toString().trim();

          // Step 1: Create the base product for THIS shop
          final productPayload = {
            "name": productName,
            "sku": "SKU-${productName.split(' ').first.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}",
            "category": stockData['category'] ?? 1,
            "shop": shopId, // Shop remains the same
            "buying_price": stockData['buying_price'], // Initial catalog price
            "selling_price": stockData['selling_price'],
          };


          final newProduct = await repository.createProduct(productPayload);


          stockData['product'] = newProduct['id'];
        }


        await repository.restockProduct(stockData);


        add(LoadStoreStocks());

      } catch (e) {
        emit(StoreError("Failed to add: ${e.toString()}"));
      }
    });

    on<SearchStoreStocks>((event, emit) {
      _currentSearch = event.query.toLowerCase();
      _applyFilters(emit);
    });

    on<FilterStoreStocks>((event, emit) {
      _currentFilter = event.filter;
      _applyFilters(emit);
    });
  }

  void _applyFilters(Emitter<StoreState> emit) {
    List<StoreStock> filtered = List.from(_allStocks);

    if (_currentFilter == 'In Stock') {
      filtered = filtered.where((s) => s.remainingQuantity > 0).toList();
    } else if (_currentFilter == 'Low Stock') {
      filtered = filtered.where((s) => s.remainingQuantity > 0 && s.remainingQuantity <= 5).toList();
    } else if (_currentFilter == 'Out of Stock') {
      filtered = filtered.where((s) => s.remainingQuantity <= 0).toList();
    }

    if (_currentSearch.isNotEmpty) {
      filtered = filtered.where((s) =>
      s.productName.toLowerCase().contains(_currentSearch) ||
          s.productSku.toLowerCase().contains(_currentSearch)).toList();
    }

    emit(StoreLoaded(filtered));
  }
}