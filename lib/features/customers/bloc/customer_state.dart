import 'package:meta/meta.dart';
import '../data/models/customer_model.dart';

@immutable
abstract class CustomerState {
  const CustomerState();

  // Adding this allows the UI to react only when data actually changes
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomerLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}