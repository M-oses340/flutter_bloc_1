import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../../data/models/expense_model.dart';
import '../widgets/add_expense_sheet.dart';
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
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(FetchExpensesRequested(widget.shopId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ExpenseBloc>(),
        child: AddExpenseSheet(shopId: widget.shopId),
      ),
    );
  }

  // Inside ExpenseListScreen
  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final query = _searchController.text.toLowerCase();

    // 1. Filter based on search
    final filtered = expenses.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.description.toLowerCase().contains(query);
    }).toList();

    // 2. ✅ Sort by Date (Latest first)
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
      final dateB = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
      return dateB.compareTo(dateA);
    });

    return filtered;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.redAccent, size: 28),
            onPressed: () => _showAddExpenseSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading && state is! ExpensesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpensesLoaded || state is ExpenseDetailLoaded || state is ExpenseActionSuccess) {
            List<Expense> all = [];
            if (state is ExpensesLoaded) {
              all = state.allExpenses;
            } else if (state is ExpenseDetailLoaded) {
              all = state.allExpenses;
            }

            final filtered = _getFilteredExpenses(all);

            return Column(
              children: [
                _buildHeader(filtered),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : _buildExpenseList(filtered),
                ),
              ],
            );
          }

          return const Center(child: Text("Unable to load expenses."));
        },
      ),
    );
  }

  Widget _buildHeader(List<Expense> filtered) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ✅ Updated from withOpacity to withValues
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 12),
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
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          ExpenseSummaryCard(expenses: filtered),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> filtered) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ExpenseBloc>().add(FetchExpensesRequested(widget.shopId)),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final expense = filtered[index];
          return ExpenseListTile(
            expense: expense,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpenseDetailScreen(expense: expense),
                ),
              );
              context.read<ExpenseBloc>().add(FetchExpenseDetailRequested(expense.id!));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ Updated from withOpacity to withValues
          Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No expenses found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}