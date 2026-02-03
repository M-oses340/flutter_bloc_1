abstract class StoreEvent {}

class LoadStoreStocks extends StoreEvent {}

class RefreshStoreStocks extends StoreEvent {}

class SearchStoreStocks extends StoreEvent {
  final String query;
  SearchStoreStocks(this.query);
}

class FilterStoreStocks extends StoreEvent {
  final String filter;
  FilterStoreStocks(this.filter);
}

// ✅ Add this event for the "Add Product to Store" functionality
class AddStoreStockEvent extends StoreEvent {
  final Map<String, dynamic> stockData;
  AddStoreStockEvent(this.stockData);
}