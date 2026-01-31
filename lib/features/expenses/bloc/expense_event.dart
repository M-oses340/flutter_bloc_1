import '../data/models/expense_model.dart';

abstract class ExpenseEvent {}

class FetchExpensesRequested extends ExpenseEvent {
  final int shopId;
  FetchExpensesRequested(this.shopId);
}

class SearchExpenseByTitle extends ExpenseEvent {
  final String query;
  SearchExpenseByTitle(this.query);
}

class FetchExpenseDetailRequested extends ExpenseEvent {
  final int expenseId;
  FetchExpenseDetailRequested(this.expenseId);
}

class CreateExpenseRequested extends ExpenseEvent {
  final Expense expense; // Changed from Map to Expense model
  CreateExpenseRequested(this.expense);
}

class DeleteExpenseRequested extends ExpenseEvent {
  final int expenseId;
  final int shopId;
  DeleteExpenseRequested(this.expenseId, this.shopId);
}