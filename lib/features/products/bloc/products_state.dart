import 'package:equatable/equatable.dart';
import '../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

/// State emitted while the "Add Product" API call is in progress
class ProductAdding extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// State emitted when a product has been successfully saved to the server
class ProductAddSuccess extends ProductState {}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}