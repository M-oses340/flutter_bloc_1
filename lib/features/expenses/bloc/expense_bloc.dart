import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc({required this.repository}) : super(ExpenseInitial()) {

    // 1. Fetch All (Initial Load)
    on<FetchExpensesRequested>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await repository.fetchExpenses(event.shopId);
        emit(ExpensesLoaded(expenses: expenses, allExpenses: expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    // 2. Local Search (Filters the list by Title)
    on<SearchExpenseByTitle>((event, emit) {
      if (state is ExpensesLoaded) {
        final currentState = state as ExpensesLoaded;
        if (event.query.isEmpty) {
          emit(ExpensesLoaded(
              expenses: currentState.allExpenses,
              allExpenses: currentState.allExpenses
          ));
        } else {
          final filtered = currentState.allExpenses
              .where((e) => e.title.toLowerCase().contains(event.query.toLowerCase()))
              .toList();
          emit(ExpensesLoaded(
              expenses: filtered,
              allExpenses: currentState.allExpenses
          ));
        }
      }
    });

    // 3. GET BY ID (Detail Fetch)
    on<FetchExpenseDetailRequested>((event, emit) async {
      emit(ExpenseLoading());
      try {
        // Ensure this method exists in your ExpenseRepository
        final expense = await repository.fetchExpenseById(event.expenseId);
        emit(ExpenseDetailLoaded(expense));
      } catch (e) {
        emit(ExpenseError("Detail Fetch Failed: ${e.toString()}"));
      }
    });

    // 4. Create (POST)
    on<CreateExpenseRequested>((event, emit) async {
      try {
        // We pass event.expense (the model) to fix the type assignment error
        await repository.addExpense(event.expense);
        emit(ExpenseActionSuccess("Expense created successfully"));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    // 5. Delete
    on<DeleteExpenseRequested>((event, emit) async {
      try {
        await repository.deleteExpense(event.expenseId);
        emit(ExpenseActionSuccess("Expense removed"));
        add(FetchExpensesRequested(event.shopId));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}