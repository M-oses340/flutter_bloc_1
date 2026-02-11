import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/sale_product_model.dart';
import '../data/repositories/make_sale_repository.dart';
import 'make_sale_event.dart';
import 'make_sale_state.dart';

class MakeSaleBloc extends Bloc<MakeSaleEvent, MakeSaleState> {
  final MakeSaleRepository repository;

  MakeSaleBloc(this.repository) : super(MakeSaleLoading()) {
    on<FetchSaleProducts>(_onFetchProducts);
    on<SearchSaleProducts>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(FetchSaleProducts event, Emitter<MakeSaleState> emit) async {
    emit(MakeSaleLoading());
    try {
      final products = await repository.fetchSaleProducts(event.shopId);
      emit(MakeSaleLoaded(
        allProducts: products,
        filteredProducts: products,
      ));
    } catch (e) {
      emit(MakeSaleError(e.toString()));
    }
  }

  void _onSearchProducts(SearchSaleProducts event, Emitter<MakeSaleState> emit) {
    final currentState = state;

    if (currentState is MakeSaleLoaded) {
      if (event.query.isEmpty) {
        emit(MakeSaleLoaded(
          allProducts: currentState.allProducts,
          filteredProducts: currentState.allProducts,
        ));
      } else {
        final query = event.query.toLowerCase();

        // 1. whereType<SaleProduct>() ensures the compiler knows items are non-null
        // 2. We perform the check on the resulting non-null list
        final filtered = currentState.allProducts.whereType<SaleProduct>().where((product) {
          // Shadowing into local variables inside the loop to satisfy the analyzer
          final String name = product.name;
          final String sku = product.sku;

          return name.toLowerCase().contains(query) ||
              sku.toLowerCase().contains(query);
        }).toList();

        emit(MakeSaleLoaded(
          allProducts: currentState.allProducts,
          filteredProducts: filtered,
        ));
      }
    }
  }
}