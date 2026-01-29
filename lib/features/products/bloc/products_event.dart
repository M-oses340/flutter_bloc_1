abstract class ProductEvent {
  const ProductEvent();
}

class GetProductsRequested extends ProductEvent {
  final int shopId;
  const GetProductsRequested(this.shopId);
}