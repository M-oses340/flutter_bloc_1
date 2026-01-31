import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/expense_summary_card.dart';
import 'expense_detail_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final int shopId;
  const ExpenseListScreen({super.key, required this.shopId});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final query = _searchController.text.toLowerCase();
    return expenses.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseDetailLoaded) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: state.expense)));
          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) return const Center(child: CircularProgressIndicator());

            if (state is ExpensesLoaded || state is ExpenseDetailLoaded) {
              final all = (state is ExpensesLoaded) ? state.allExpenses : (state as ExpenseDetailLoaded).allExpenses;
              final filtered = _getFilteredExpenses(all);

              return Column(
                children: [
                  // FIXED HEADER with subtle shadow to separate from the list
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 12), // Tighter bottom padding
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: "Search transactions...",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF1F2F6),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none
                              ),
                            ),
                          ),
                        ),
                        // Summary card now sits closer to the search bar
                        ExpenseSummaryCard(expenses: filtered),
                      ],
                    ),
                  ),

                  // SCROLLABLE LIST
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                      onRefresh: () async => context.read<ExpenseBloc>().add(FetchExpensesRequested(widget.shopId)),
                      child: ListView.builder(
                        // Standardized padding
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => ExpenseListTile(
                          expense: filtered[index],
                          onTap: () => context.read<ExpenseBloc>().add(
                            FetchExpenseDetailRequested(filtered[index].id!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("Unable to load expenses."));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        elevation: 4,
        label: const Text("Add Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // TODO: Open Create Expense Screen
        },
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No expenses found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}