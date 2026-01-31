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

  // --- ACTIONS ---

  void _handleEdit(BuildContext context, Expense currentExpense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ExpenseBloc>(),
        child: EditExpenseSheet(expense: currentExpense),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Expense currentExpense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Expense?"),
        content: Text("Are you sure you want to delete ${currentExpense.title}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.read<ExpenseBloc>().add(DeleteExpenseRequested(currentExpense));
              Navigator.pop(context); // Return to list screen
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        // ✅ DYNAMIC DATA LOGIC
        // We check for ExpenseDetailLoaded to get the fresh data.
        // If the state is something else (like Success or Loading), we still
        // want to show the 'expense' but we need to be careful it's not stale.
        // This is why emitting ExpenseDetailLoaded in your Bloc is so important!

        final current = (state is ExpenseDetailLoaded) ? state.expense : expense;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Expense Details", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            actions: [
              _buildPopupMenu(context, current),
            ],
          ),
          body: _buildBody(current),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, Expense current) {
    return PopupMenuButton<String>(
      onSelected: (val) => val == 'edit' ? _handleEdit(context, current) : _showDeleteConfirm(context, current),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 8),
              Text("Edit Expense"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(Expense e) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PURPOSE", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(e.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          const SizedBox(height: 24),

          const Text("AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(
            "KSh ${e.amount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.redAccent),
          ),

          const Divider(height: 48, thickness: 1),

          const Text("DETAILS", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              e.description.isNotEmpty ? e.description : "No additional details provided.",
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 40),

          _buildInfoRow(Icons.person_outline, "Created By", e.userName ?? "System"),
          _buildInfoRow(Icons.calendar_today_outlined, "Date", _formatDate(e.createdAt)),
          _buildInfoRow(Icons.storefront_outlined, "Shop ID", e.shopId.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                shape: BoxShape.circle
            ),
            child: Icon(icon, size: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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