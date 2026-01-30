import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsRequested extends ProductEvent {
  final int shopId;
  const GetProductsRequested(this.shopId);

  @override
  List<Object?> get props => [shopId];
}

class AddProductRequested extends ProductEvent {
  final Map<String, dynamic> productData;
  final File? imageFile;
  final int shopId;

  const AddProductRequested({
    required this.productData,
    this.imageFile,
    required this.shopId,
  });

  @override
  List<Object?> get props => [productData, imageFile, shopId];
}

class FilterByCategoryRequested extends ProductEvent {
  final int categoryId;
  final int shopId;

  const FilterByCategoryRequested({
    required this.categoryId,
    required this.shopId
  });

  @override
  List<Object?> get props => [categoryId, shopId];
}

class GetProductDetailsRequested extends ProductEvent {
  final int productId;
  const GetProductDetailsRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductRequested extends ProductEvent {
  final int productId;
  final Map<String, dynamic> productData;
  final File? imageFile;
  final int shopId;
  final bool usePut;

  const UpdateProductRequested({
    required this.productId,
    required this.productData,
    this.imageFile,
    required this.shopId,
    this.usePut = false,
  });

  @override
  List<Object?> get props => [productId, productData, imageFile, shopId, usePut];
}
