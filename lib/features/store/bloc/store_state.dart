import '../data/models/store_stock.dart';

abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreStock> stocks;
  StoreLoaded(this.stocks);
}

class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}