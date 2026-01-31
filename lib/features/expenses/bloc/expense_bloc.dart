import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart'; // Ensure this path is correct
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc({required this.repository}) : super(ExpenseInitial()) {

    on<FetchExpensesRequested>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await repository.fetchExpenses(event.shopId);
        emit(ExpensesLoaded(expenses: expenses, allExpenses: expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<SearchExpenseByTitle>((event, emit) {
      final currentState = state;
      if (currentState is ExpensesLoaded || currentState is ExpenseDetailLoaded) {
        // Get the full list from whichever state we are currently in
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

    on<DeleteExpenseRequested>((event, emit) async {
      try {
        await repository.deleteExpense(event.expenseId);
        // Refresh the list after deletion to keep UI in sync
        add(FetchExpensesRequested(event.shopId));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<AddExpenseRequested>((event, emit) async {
      try {
        // We use the model passed inside the event
        await repository.addExpense(event.expense);

        // Refresh the list immediately using the shop ID from the model
        add(FetchExpensesRequested(event.expense.shopId));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}