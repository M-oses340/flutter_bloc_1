import '../data/models/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  CustomerLoaded(this.customers);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}