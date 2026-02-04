import '../data/models/store_stock.dart';

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


class AddStoreStockEvent extends StoreEvent {
  final Map<String, dynamic> stockData;
  AddStoreStockEvent(this.stockData);
}


class TransferStockEvent extends StoreEvent {
  final StoreStock stock;
  final double quantity;

  TransferStockEvent({
    required this.stock,
    required this.quantity,
  });
}