import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc({required this.repository}) : super(ExpenseInitial()) {


    // Inside your ExpenseBloc
    on<FetchExpensesRequested>((event, emit) async {
      try {
        emit(ExpenseLoading());
        final expenses = await repository.fetchExpenses(event.shopId);

        // ✅ Sort: Newest/Most recently updated first
        expenses.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final dateB = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return dateB.compareTo(dateA); // Descending order
        });

        emit(ExpensesLoaded(expenses: expenses, allExpenses: expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    // 2. SEARCH / FILTER
    on<SearchExpenseByTitle>((event, emit) {
      final currentState = state;
      if (currentState is ExpensesLoaded || currentState is ExpenseDetailLoaded) {
        final List<Expense> pool = (currentState is ExpensesLoaded)
            ? currentState.allExpenses
            : (currentState as ExpenseDetailLoaded).allExpenses;

        if (event.query.isEmpty) {
          emit(ExpensesLoaded(expenses: pool, allExpenses: pool));
        } else {
          final filtered = pool
              .where((e) => e.title.toLowerCase().contains(event.query.toLowerCase()))
              .toList();
          emit(ExpensesLoaded(expenses: filtered, allExpenses: pool));
        }
      }
    });


    on<FetchExpenseDetailRequested>((event, emit) async {
      List<Expense> currentExpenses = [];
      if (state is ExpensesLoaded) {
        currentExpenses = (state as ExpensesLoaded).allExpenses;
      } else if (state is ExpenseDetailLoaded) {
        currentExpenses = (state as ExpenseDetailLoaded).allExpenses;
      }

      try {
        final expenseDetail = await repository.fetchExpenseById(event.expenseId);
        emit(ExpenseDetailLoaded(
          expense: expenseDetail,
          allExpenses: currentExpenses,
        ));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });


    on<AddExpenseRequested>((event, emit) async {
      try {
        await repository.addExpense(event.expense);
        emit(ExpenseActionSuccess("Expense added successfully"));
        add(FetchExpensesRequested(event.expense.shopId));
      } catch (e) {
        emit(ExpenseError("Failed to add: ${e.toString()}"));
      }
    });

    on<UpdateExpenseRequested>((event, emit) async {
      try {

        await repository.updateExpense(
          event.expense.id!,
          event.expense,
          usePatch: true,
        );

        emit(ExpenseDetailLoaded(
          expense: event.expense,
          allExpenses: state is ExpensesLoaded ? (state as ExpensesLoaded).allExpenses : [],
        ));

        emit(ExpenseActionSuccess("Expense updated successfully"));


        add(FetchExpensesRequested(event.expense.shopId));

      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });


    on<DeleteExpenseRequested>((event, emit) async {
      try {
        await repository.deleteExpense(event.expense.id!);
        emit(ExpenseActionSuccess("Expense deleted successfully"));

        // Use shopId from the model to refresh the correct list
        add(FetchExpensesRequested(event.expense.shopId));
      } catch (e) {
        emit(ExpenseError("Delete failed: ${e.toString()}"));
      }
    });
  }
}