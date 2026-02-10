import 'package:meta/meta.dart';
import '../data/models/customer_model.dart';

@immutable
abstract class CustomerState {
  const CustomerState();
}

/// The initial state before any action is taken
class CustomerInitial extends CustomerState {}

/// State emitted while fetching data or performing an async operation
class CustomerLoading extends CustomerState {}

/// State emitted when customers are successfully fetched or updated
class CustomerLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomerLoaded(this.customers);

  // Helps BLoC compare lists to decide if the UI should rebuild
  List<Object> get props => [customers];
}

/// State emitted when an error occurs (e.g., the 403 Forbidden error)
class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  List<Object> get props => [message];
}