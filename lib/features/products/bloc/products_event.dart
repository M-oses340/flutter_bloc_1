abstract class ProductEvent {
  const ProductEvent();
}

class GetProductsRequested extends ProductEvent {
  final int shopId;
  const GetProductsRequested(this.shopId);
}

/// Event triggered when the user submits the Add Product form
class AddProductRequested extends ProductEvent {
  final Map<String, dynamic> productData;
  final int shopId;

  const AddProductRequested({
    required this.productData,
    required this.shopId,
  });
}
class FilterByCategoryRequested extends ProductEvent {
  final int categoryId;
  final int shopId;

  const FilterByCategoryRequested({required this.categoryId, required this.shopId});

  List<Object?> get props => [categoryId, shopId];
}