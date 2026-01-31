import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import 'expense_list_tile.dart';

class ExpenseSearchDelegate extends SearchDelegate {
  final int shopId;

  ExpenseSearchDelegate(this.shopId);

  // ✅ Theme Override: Ensures the search bar background and text match your theme
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onSurface),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

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
    if (query.isNotEmpty) {
      context.read<ExpenseBloc>().add(SearchExpenseByTitle(query));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      // ✅ FIX: Match search background to theme surface
      color: colorScheme.surface,
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpensesLoaded) {
            final results = state.expenses;

            if (results.isEmpty) {
              return Center(
                child: Text(
                  "No expenses found with that title.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final expense = results[index];
                return ExpenseListTile(
                  expense: expense,
                  onTap: () {
                    context.read<ExpenseBloc>().add(FetchExpenseDetailRequested(expense.id!));
                    close(context, null);
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        },
      ),
    );
  }
}