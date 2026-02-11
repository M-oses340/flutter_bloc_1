import '../data/models/sale_product_model.dart';


abstract class MakeSaleState {}

class MakeSaleLoading extends MakeSaleState {}

class MakeSaleLoaded extends MakeSaleState {
  final List<SaleProduct> allProducts;
  final List<SaleProduct> filteredProducts;

  MakeSaleLoaded({
    required this.allProducts,
    required this.filteredProducts,
  });
}

class MakeSaleError extends MakeSaleState {
  final String message;
  MakeSaleError(this.message);
}