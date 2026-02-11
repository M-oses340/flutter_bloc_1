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
    on<AddProductToCart>(_onAddToCart);
  }

  Future<void> _onFetchProducts(FetchSaleProducts event, Emitter<MakeSaleState> emit) async {
    emit(MakeSaleLoading());
    try {
      final products = await repository.fetchSaleProducts(event.shopId);
      emit(MakeSaleLoaded(
        allProducts: products,
        filteredProducts: products,
        cartItems: [],
        totalAmount: 0.0,
      ));
    } catch (e) {
      emit(MakeSaleError(e.toString()));
    }
  }

  void _onSearchProducts(SearchSaleProducts event, Emitter<MakeSaleState> emit) {
    final currentState = state;

    if (currentState is MakeSaleLoaded) {
      final query = event.query.toLowerCase();

      final filtered = query.isEmpty
          ? currentState.allProducts
          : currentState.allProducts.whereType<SaleProduct>().where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query);
      }).toList();

      // Using copyWith preserves the current cartItems and totalAmount
      emit(currentState.copyWith(filteredProducts: filtered));
    }
  }

  void _onAddToCart(AddProductToCart event, Emitter<MakeSaleState> emit) {
    final currentState = state;
    if (currentState is MakeSaleLoaded) {
      // 1. Create a new list for the cart to ensure a new state reference
      final updatedCart = List<SaleProduct>.from(currentState.cartItems)
        ..add(event.product);

      // 2. Calculate the total using the 'price' field from your SaleProduct model
      final double newTotal = updatedCart.fold(
        0.0,
            (sum, item) => sum + item.price,
      );

      // 3. Emit updated state with the new cart and total
      emit(currentState.copyWith(
        cartItems: updatedCart,
        totalAmount: newTotal,
      ));
    }
  }
}