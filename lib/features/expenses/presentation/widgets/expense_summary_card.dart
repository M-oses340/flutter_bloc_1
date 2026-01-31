import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final double total = expenses.fold(0, (sum, item) => sum + item.amount);

    return Container(
      width: double.infinity,
      // Reduced vertical padding from 40 to 24
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E272E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Forces the column to wrap its content tightly
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "TOTAL EXPENDITURE",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11, // Slightly smaller
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 16
          Text(
            "KSh ${total.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34, // Reduced from 42
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          // Optional: Remove the transaction badge container if you want it even shorter
          Text(
            "${expenses.length} Transactions",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}