import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<GetProductsRequested>(_onGetProductsRequested);
    on<AddProductRequested>(_onAddProductRequested);
    on<FilterByCategoryRequested>(_onFilterByCategoryRequested);
  }


  Future<void> _onGetProductsRequested(
      GetProductsRequested event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts(event.shopId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }


  Future<void> _onFilterByCategoryRequested(
      FilterByCategoryRequested event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProductsByCategory(
        event.categoryId,
        event.shopId,
      );
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }


  Future<void> _onAddProductRequested(
      AddProductRequested event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductAdding());
    try {
      // Correctly passing text data AND the image file
      await repository.addProduct(
        event.productData,
        event.imageFile,
      );

      emit(ProductAddSuccess());


      add(GetProductsRequested(event.shopId));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}