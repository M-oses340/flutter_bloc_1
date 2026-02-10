import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/customer_repository.dart';
import '../data/models/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;

  CustomerBloc({required this.repository}) : super(CustomerInitial()) {

    // 🔍 Handle Fetching
    on<FetchCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customers = await repository.fetchCustomers(event.shopId);
        emit(CustomerLoaded(customers));
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(CustomerError(errorMsg));
      }
    });

    // ➕ Handle Adding
    on<AddCustomerEvent>((event, emit) async {
      final currentState = state;

      try {
        final newCustomer = await repository.addCustomer({
          "name": event.name,
          "phone_number": event.phoneNumber,
          "shop": event.shopId,
        });


        if (currentState is CustomerLoaded) {
          final updatedList = List<Customer>.from(currentState.customers)..insert(0, newCustomer);
          emit(CustomerLoaded(updatedList));
        } else {
          add(FetchCustomers(event.shopId));
        }
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(CustomerError("Failed to add customer: $errorMsg"));
        if (currentState is CustomerLoaded) emit(CustomerLoaded(currentState.customers));
      }
    });

    // 🗑️ Handle Deletion
    on<DeleteCustomerEvent>((event, emit) async {
      final currentState = state;
      try {
        await repository.deleteCustomer(event.customerId);

        if (currentState is CustomerLoaded) {
          final updatedList = currentState.customers
              .where((c) => c.id != event.customerId)
              .toList();
          emit(CustomerLoaded(updatedList));
        }
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(CustomerError("Could not delete: $errorMsg"));
        if (currentState is CustomerLoaded) emit(CustomerLoaded(currentState.customers));
      }
    });
  }
}