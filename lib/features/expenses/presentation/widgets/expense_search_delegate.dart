import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import 'expense_list_tile.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  final int shopId;

  ExpenseSearchDelegate(this.shopId);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    // Triggers the local search in the Bloc every time the query changes
    if (query.isNotEmpty) {
      context.read<ExpenseBloc>().add(SearchExpenseByTitle(query));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpensesLoaded) {
          final results = state.expenses;

          if (results.isEmpty) {
            return const Center(child: Text("No expenses found with that title."));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final expense = results[index];
              return ExpenseListTile(
                expense: expense,
                onTap: () {
                  // When selected, trigger the GET by ID
                  context.read<ExpenseBloc>().add(FetchExpenseDetailRequested(expense.id!));
                  close(context, null); // Close search overlay
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}