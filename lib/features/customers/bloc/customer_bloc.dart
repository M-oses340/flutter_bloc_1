import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/customer_repository.dart';
import '../data/models/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;

  CustomerBloc({required this.repository}) : super(CustomerInitial()) {

    // Handle Fetching
    on<FetchCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customers = await repository.getCustomers(event.shopId);
        emit(CustomerLoaded(customers));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    // Handle Adding
    on<AddCustomerEvent>((event, emit) async {
      // We keep the current list in memory if we are already in Loaded state
      final currentState = state;
      try {
        final newCustomer = await repository.createCustomer(
          name: event.name,
          phoneNumber: event.phoneNumber,
          shopId: event.shopId,
        );

        if (currentState is CustomerLoaded) {
          // Add the new customer to the existing list immediately for smooth UI
          final updatedList = List<Customer>.from(currentState.customers)..add(newCustomer);
          emit(CustomerLoaded(updatedList));
        } else {
          // If list wasn't loaded, just fetch fresh
          add(FetchCustomers(event.shopId));
        }
      } catch (e) {
        emit(CustomerError("Failed to add customer: $e"));
      }
    });
  }
}