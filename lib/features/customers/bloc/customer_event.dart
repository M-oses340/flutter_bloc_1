import 'package:flutter/material.dart';

@immutable
abstract class CustomerEvent {
  const CustomerEvent();
}

/// Event to trigger fetching the customer list from the server
class FetchCustomers extends CustomerEvent {
  final int shopId;

  const FetchCustomers(this.shopId);

  // Added for equality checks in testing or complex logic
  List<Object> get props => [shopId];
}

/// Event to create a new customer
class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String phoneNumber;
  final int shopId;

  const AddCustomerEvent({
    required this.name,
    required this.phoneNumber,
    required this.shopId,
  });

  List<Object> get props => [name, phoneNumber, shopId];
}


class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  List<Object> get props => [query];
}

class DeleteCustomerEvent extends CustomerEvent {
  final int customerId;
  final int shopId; // Needed to refresh or find context

  const DeleteCustomerEvent({required this.customerId, required this.shopId});

  List<Object> get props => [customerId, shopId];
}