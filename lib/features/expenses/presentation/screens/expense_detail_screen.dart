import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../widgets/edit_expense_sheet.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  void _handleEdit(BuildContext context, Expense currentExpense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Keeps the sheet's internal styling
      builder: (_) => BlocProvider.value(
        value: context.read<ExpenseBloc>(),
        child: EditExpenseSheet(expense: currentExpense),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Expense currentExpense) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Expense?"),
        content: Text("Are you sure you want to delete ${currentExpense.title}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ExpenseBloc>().add(DeleteExpenseRequested(currentExpense));
              Navigator.pop(context);
            },
            child: Text(
                "Delete",
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        final current = (state is ExpenseDetailLoaded) ? state.expense : expense;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Expense Details", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            // ✅ Removal of hardcoded black/white for adaptive theme logic
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
            actions: [
              _buildPopupMenu(context, current, colorScheme),
            ],
          ),
          body: _buildBody(context, current),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, Expense current, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (val) => val == 'edit' ? _handleEdit(context, current) : _showDeleteConfirm(context, current),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              const Text("Edit Expense"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
              const SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Expense e) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedStyle = TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        letterSpacing: 1.2
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PURPOSE", style: mutedStyle),
          const SizedBox(height: 4),
          Text(
              e.title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
          ),

          const SizedBox(height: 24),

          Text("AMOUNT", style: mutedStyle),
          const SizedBox(height: 4),
          Text(
            "KSh ${e.amount.toStringAsFixed(2)}",
            style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.error // Consistent red for expenses
            ),
          ),

          Divider(height: 48, thickness: 1, color: theme.dividerColor),

          Text("DETAILS", style: mutedStyle),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ✅ FIX: Using tonal container instead of grey.shade50
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Text(
              e.description.isNotEmpty ? e.description : "No additional details provided.",
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),

          const SizedBox(height: 40),

          _buildInfoRow(context, Icons.person_outline, "Created By", e.userName ?? "System"),
          _buildInfoRow(context, Icons.calendar_today_outlined, "Date", _formatDate(e.createdAt)),
          _buildInfoRow(context, Icons.storefront_outlined, "Shop ID", e.shopId.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
              Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      return dateStr.split('T').first;
    } catch (_) {
      return dateStr;
    }
  }
}