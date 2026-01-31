import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseListTile({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            expense.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              // ✅ FIX: Standard color that flips between black and white
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "${expense.description} • ${expense.userName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // ✅ FIX: Muted color that stays visible in both modes
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          trailing: Text(
            "KSh ${expense.amount.toStringAsFixed(0)}",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        // ✅ FIX: Adaptive divider color
        Divider(
          height: 1,
          indent: 24,
          endIndent: 24,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}