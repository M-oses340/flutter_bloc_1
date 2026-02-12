abstract class MakeSaleEvent {}

class FetchSaleProducts extends MakeSaleEvent {
  final int shopId;
  FetchSaleProducts(this.shopId);
}

class SearchSaleProducts extends MakeSaleEvent {
  final String query;
  SearchSaleProducts(this.query);
}

class AddProductToCart extends MakeSaleEvent {
  final dynamic product; // Replace 'dynamic' with your Product model type
  AddProductToCart(this.product);
}
class RemoveProductFromCart extends MakeSaleEvent {
  final int productId;
  RemoveProductFromCart(this.productId);
}

class IncrementCartItem extends MakeSaleEvent {
  final int productId;
  IncrementCartItem(this.productId);
}

class DecrementCartItem extends MakeSaleEvent {
  final int productId;
  DecrementCartItem(this.productId);
}