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
    on<RemoveProductFromCart>(_onRemoveFromCart);
    on<IncrementCartItem>(_onIncrement);
    on<DecrementCartItem>(_onDecrement);
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
    if (state is MakeSaleLoaded) {
      final currentState = state as MakeSaleLoaded;
      final query = event.query.toLowerCase();

      final filtered = query.isEmpty
          ? currentState.allProducts
          : currentState.allProducts.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(filteredProducts: filtered));
    }
  }

  void _onAddToCart(AddProductToCart event, Emitter<MakeSaleState> emit) {
    if (state is MakeSaleLoaded) {
      final currentState = state as MakeSaleLoaded;
      final updatedCart = List<SaleProduct>.from(currentState.cartItems)..add(event.product);

      emit(currentState.copyWith(
        cartItems: updatedCart,
        totalAmount: _calculateTotal(updatedCart),
      ));
    }
  }

  void _onRemoveFromCart(RemoveProductFromCart event, Emitter<MakeSaleState> emit) {
    if (state is MakeSaleLoaded) {
      final currentState = state as MakeSaleLoaded;
      final updatedCart = currentState.cartItems.where((item) => item.id != event.productId).toList();

      emit(currentState.copyWith(
        cartItems: updatedCart,
        totalAmount: _calculateTotal(updatedCart),
      ));
    }
  }

  void _onIncrement(IncrementCartItem event, Emitter<MakeSaleState> emit) {
    if (state is MakeSaleLoaded) {
      final currentState = state as MakeSaleLoaded;
      // Find the product template from the master list
      final product = currentState.allProducts.firstWhere((p) => p.id == event.productId);
      final updatedCart = List<SaleProduct>.from(currentState.cartItems)..add(product);

      emit(currentState.copyWith(
        cartItems: updatedCart,
        totalAmount: _calculateTotal(updatedCart),
      ));
    }
  }

  void _onDecrement(DecrementCartItem event, Emitter<MakeSaleState> emit) {
    if (state is MakeSaleLoaded) {
      final currentState = state as MakeSaleLoaded;
      final updatedCart = List<SaleProduct>.from(currentState.cartItems);


      final index = updatedCart.lastIndexWhere((item) => item.id == event.productId);
      if (index != -1) {
        updatedCart.removeAt(index);
      }

      emit(currentState.copyWith(
        cartItems: updatedCart,
        totalAmount: _calculateTotal(updatedCart),
      ));
    }
  }

  double _calculateTotal(List<SaleProduct> items) {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }
}