import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/expense_search_delegate.dart';
import 'expense_detail_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  final int shopId;

  const ExpenseListScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        title: const Text(
          "Expenses",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => showSearch(
              context: context,
              delegate: ExpenseSearchDelegate(shopId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseDetailLoaded) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseDetailScreen(expense: state.expense),
              ),
            );
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            // Logic to ensure list is visible even in DetailLoaded state
            if (state is ExpensesLoaded || state is ExpenseDetailLoaded) {
              final List<Expense> currentList = (state is ExpensesLoaded)
                  ? state.expenses
                  : (state as ExpenseDetailLoaded).allExpenses;

              return RefreshIndicator(
                color: theme.primaryColor,
                onRefresh: () async => context
                    .read<ExpenseBloc>()
                    .add(FetchExpensesRequested(shopId)),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Summary Header
                    SliverToBoxAdapter(
                      child: ExpenseSummaryCard(expenses: currentList),
                    ),

                    // 2. Section Title
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    // 3. Scrollable List
                    currentList.isEmpty
                        ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("No expenses found for this period."),
                      ),
                    )
                        : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final expense = currentList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: ExpenseListTile(
                                expense: expense,
                                onTap: () => context.read<ExpenseBloc>().add(
                                  FetchExpenseDetailRequested(expense.id!),
                                ),
                              ),
                            );
                          },
                          childCount: currentList.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Tap 'Add Expense' to get started"),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          // BottomSheet or Navigation to CreateExpenseScreen
        },
      ),
    );
  }
}