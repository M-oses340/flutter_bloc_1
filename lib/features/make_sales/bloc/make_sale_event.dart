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