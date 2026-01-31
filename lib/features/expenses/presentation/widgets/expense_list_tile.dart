import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseListTile({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          // Extra horizontal padding to align with your big header card
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            expense.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2D3436),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              // Using description + username since category isn't in your JSON
              "${expense.description} • ${expense.userName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          trailing: Text(
            "KSh ${expense.amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.w900, // Thicker weight for premium feel
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        // Subtle divider that doesn't hit the edges
        const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF1F2F6)),
      ],
    );
  }
}