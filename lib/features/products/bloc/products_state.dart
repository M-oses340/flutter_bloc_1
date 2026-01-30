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


class ProductAddSuccess extends ProductState {}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailsLoaded extends ProductState {
  final Product product;
  const ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}