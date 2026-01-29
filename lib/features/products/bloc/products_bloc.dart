import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;


  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<GetProductsRequested>(_onGetProductsRequested);
  }

  Future<void> _onGetProductsRequested(
      GetProductsRequested event,
      Emitter<ProductState> emit
      ) async {
    emit(ProductLoading());
    try {

      final products = await repository.fetchProducts(event.shopId);
      emit(ProductLoaded(products));
    } catch (e) {
      // Handle potential errors like "No token found" or "Server Error"
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}