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
    on<GetProductDetailsRequested>(_onGetProductDetailsRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
  }



  Future<void> _onGetProductsRequested(GetProductsRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProducts(event.shopId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onGetProductDetailsRequested(GetProductDetailsRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await repository.fetchProductById(event.productId);
      emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdateProductRequested(UpdateProductRequested event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      final updatedProduct = await repository.updateProduct(
        productId: event.productId,
        productData: event.productData,
        imageFile: event.imageFile,
        isFullUpdate: event.usePut,
      );

      // 1. Signal the Edit screen to pop immediately
      emit(ProductAddSuccess());

      // 2. Give the Navigator a split second to start the transition
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Emit the loaded state so the details page has data to show
      emit(ProductDetailsLoaded(updatedProduct));

      // 4. Refresh the product list (this usually emits a different state like ProductListLoaded)
      add(GetProductsRequested(event.shopId));

    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onFilterByCategoryRequested(FilterByCategoryRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.fetchProductsByCategory(event.categoryId, event.shopId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onAddProductRequested(AddProductRequested event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      await repository.addProduct(event.productData, event.imageFile);
      emit(ProductAddSuccess());
      add(GetProductsRequested(event.shopId));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll("Exception: ", "")));
    }
  }
  // Inside ProductBloc


  Future<void> _onDeleteProductRequested(DeleteProductRequested event, Emitter<ProductState> emit) async {
    // We can use ProductAdding or create a ProductDeleting state
    emit(ProductAdding());

    try {
      await repository.deleteProduct(event.productId);

      // 1. Emit success so the UI can navigate away
      emit(ProductAddSuccess());

      // 2. Refresh the main list so the deleted item disappears
      add(GetProductsRequested(event.shopId));

    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}