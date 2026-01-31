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

class AddExpenseRequested extends ExpenseEvent {
  final Expense expense;
  AddExpenseRequested(this.expense);
}
class DeleteExpenseRequested extends ExpenseEvent {
  final Expense expense;
  DeleteExpenseRequested(this.expense);
}
class UpdateExpenseRequested extends ExpenseEvent {
  final Expense expense;
  UpdateExpenseRequested(this.expense);
}