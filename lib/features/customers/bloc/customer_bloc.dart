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
        // ✅ Updated to match fetchCustomers in your new repository
        final customers = await repository.fetchCustomers(event.shopId);
        emit(CustomerLoaded(customers));
      } catch (e) {
        // Strip "Exception: " prefix for a cleaner UI message
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(CustomerError(errorMsg));
      }
    });

    // ➕ Handle Adding
    on<AddCustomerEvent>((event, emit) async {
      final currentState = state;

      try {
        // ✅ Updated to use the Map-based addCustomer method
        final newCustomer = await repository.addCustomer({
          "name": event.name,
          "phone_number": event.phoneNumber,
          "shop": event.shopId,
        });

        if (currentState is CustomerLoaded) {
          // Update the list locally for an instant UI response
          final updatedList = List<Customer>.from(currentState.customers)..insert(0, newCustomer);
          emit(CustomerLoaded(updatedList));
        } else {
          // If state wasn't loaded, trigger a fresh fetch
          add(FetchCustomers(event.shopId));
        }
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        emit(CustomerError("Failed to add customer: $errorMsg"));

        // Optional: If adding fails, revert to the previous loaded list if it existed
        if (currentState is CustomerLoaded) {
          emit(CustomerLoaded(currentState.customers));
        }
      }
    });
  }
}