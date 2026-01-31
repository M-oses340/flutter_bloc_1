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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // AlertDialog background and text colors are handled by the theme automatically
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            // ✅ Use onSurfaceVariant for secondary actions
            child: Text(
                "Cancel",
                style: TextStyle(color: colorScheme.onSurfaceVariant)
            ),
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
            // ✅ Use theme's error color for consistency
            child: Text(
                "Delete",
                style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      // ✅ Using colorScheme.error for the icon
      icon: Icon(Icons.delete_outline, color: colorScheme.error),
      onPressed: () => _showDeleteDialog(context),
    );
  }
}