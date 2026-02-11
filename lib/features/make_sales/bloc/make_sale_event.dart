abstract class MakeSaleEvent {}

class FetchSaleProducts extends MakeSaleEvent {
  final int shopId;
  FetchSaleProducts(this.shopId);
}

class SearchSaleProducts extends MakeSaleEvent {
  final String query;
  SearchSaleProducts(this.query);
}