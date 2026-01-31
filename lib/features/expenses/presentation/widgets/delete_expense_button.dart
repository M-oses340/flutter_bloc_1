import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../data/models/expense_model.dart';

class DeleteExpenseButton extends StatelessWidget {
  final Expense expense;

  const DeleteExpenseButton({
    super.key,
    required this.expense,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Dispatch delete event using the main context and the expense model
              context.read<ExpenseBloc>().add(
                DeleteExpenseRequested(expense),
              );

              // Close Dialog
              Navigator.pop(dialogContext);

              // Go back to the List Screen (pops the Detail Screen)
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
      onPressed: () => _showDeleteDialog(context),
    );
  }
}