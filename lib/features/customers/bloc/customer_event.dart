abstract class CustomerEvent {}

class FetchCustomers extends CustomerEvent {
  final int shopId;
  FetchCustomers(this.shopId);
}

class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String phoneNumber;
  final int shopId;

  AddCustomerEvent({
    required this.name,
    required this.phoneNumber,
    required this.shopId
  });
}