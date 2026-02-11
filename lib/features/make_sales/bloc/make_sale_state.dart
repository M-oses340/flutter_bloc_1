import '../data/models/sale_product_model.dart';

abstract class MakeSaleState {}

class MakeSaleInitial extends MakeSaleState {}

class MakeSaleLoading extends MakeSaleState {}

class MakeSaleLoaded extends MakeSaleState {
  final List<SaleProduct> allProducts;
  final List<SaleProduct> filteredProducts;
  // --- Cart Data ---
  final List<SaleProduct> cartItems;
  final double totalAmount;

  MakeSaleLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.cartItems = const [],
    this.totalAmount = 0.0,
  });

  // Helper method to update state easily
  MakeSaleLoaded copyWith({
    List<SaleProduct>? allProducts,
    List<SaleProduct>? filteredProducts,
    List<SaleProduct>? cartItems,
    double? totalAmount,
  }) {
    return MakeSaleLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class MakeSaleError extends MakeSaleState {
  final String message;
  MakeSaleError(this.message);
}