import '../data/models/store_stock.dart';

abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

// 🏥 State for when the "Catch" (Restoration) is happening
class StoreRestoring extends StoreState {
  final String productName;
  StoreRestoring(this.productName);
}

class StoreLoaded extends StoreState {
  final List<StoreStock> stocks;
  StoreLoaded(this.stocks);
}

// ✅ NEW: Specific success state for the Transfer action
class StoreTransferSuccess extends StoreState {
  final String message;
  StoreTransferSuccess({this.message = "Transfer completed successfully"});
}

class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}