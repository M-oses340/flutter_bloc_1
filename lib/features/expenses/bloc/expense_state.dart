import '../data/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}
class ExpenseLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;      // The filtered list shown in UI
  final List<Expense> allExpenses;   // The original list from server
  ExpensesLoaded({required this.expenses, required this.allExpenses});
}

class ExpenseDetailLoaded extends ExpenseState {
  final Expense expense;
  final List<Expense> allExpenses;

  ExpenseDetailLoaded({required this.expense, required this.allExpenses});

  List<Object?> get props => [expense, allExpenses];
}

class ExpenseActionSuccess extends ExpenseState {
  final String message;
  ExpenseActionSuccess(this.message);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}