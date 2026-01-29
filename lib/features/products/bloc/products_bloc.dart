import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    // Register the handlers
    on<GetProductsRequested>(_onGetProductsRequested);
    on<AddProductRequested>(_onAddProductRequested);
  }

  // Fetch Logic
  Future<void> _onGetProductsRequested(
      GetProductsRequested event,
      Emitter<ProductState> emit
      ) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts(event.shopId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  // Add Product Logic
  Future<void> _onAddProductRequested(
      AddProductRequested event,
      Emitter<ProductState> emit
      ) async {
    // We keep the current state (ProductLoaded) while adding to avoid
    // flickering the screen, or you can emit a specialized loading state.
    try {
      await repository.addProduct(event.productData);

      // 1. Emit success so the UI can close the form
      emit(ProductAddSuccess());

      // 2. Refresh the list automatically
      add(GetProductsRequested(event.shopId));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}