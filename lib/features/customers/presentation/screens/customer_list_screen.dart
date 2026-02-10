import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/customer_bloc.dart';
import '../../bloc/customer_event.dart';
import '../../bloc/customer_state.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_search_bar.dart';
import 'add_customer_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Initially fetch customers for shop_id = 1
    // In a real app, this ID would come from your Auth/Shop provider
    context.read<CustomerBloc>().add(FetchCustomers(1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("All Customers"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            // Uses primaryTeal from your AppTheme
            icon: Icon(
              Icons.add_circle_outline,
              color: colorScheme.primary,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    // Pass the existing bloc instance from the current context
                    value: context.read<CustomerBloc>(),
                    child: const AddCustomerScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Decoupled Search Bar Widget
          CustomerSearchBar(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          // Main List View Logic
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                if (state is CustomerLoaded) {
                  // Perform real-time filtering
                  final filteredCustomers = state.customers.where((customer) {
                    final nameMatch = customer.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    final phoneMatch = customer.phoneNumber.contains(_searchQuery);
                    return nameMatch || phoneMatch;
                  }).toList();

                  if (filteredCustomers.isEmpty) {
                    return Center(
                      child: Text(
                        "No customers found",
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: colorScheme.primary,
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(FetchCustomers(1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        return CustomerCard(customer: filteredCustomers[index]);
                      },
                    ),
                  );
                }

                if (state is CustomerError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}