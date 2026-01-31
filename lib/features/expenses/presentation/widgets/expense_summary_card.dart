import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double total = expenses.fold(0, (sum, item) => sum + item.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ✅ FIX: Uses Primary for Light Mode, and surface elevation for Dark Mode
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "TOTAL EXPENDITURE",
            style: TextStyle(
              // ✅ Uses 'onPrimary' for light, 'onSurface' for dark
              color: (isDark ? colorScheme.onSurfaceVariant : colorScheme.onPrimary)
                  .withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "KSh ${total.toStringAsFixed(0)}",
            style: TextStyle(
              color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${expenses.length} Transactions",
            style: TextStyle(
              color: (isDark ? colorScheme.onSurfaceVariant : colorScheme.onPrimary)
                  .withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}