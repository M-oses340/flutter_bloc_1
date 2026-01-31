import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Record")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PURPOSE", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
            Text(expense.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text("AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
            Text("KSh ${expense.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.redAccent)),

            const Divider(height: 40),

            const Text("DETAILS", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                expense.description.isNotEmpty ? expense.description : "No additional details provided.",
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
            _buildInfoRow(Icons.person_outline, "Created By", expense.userName ?? "System"),
            _buildInfoRow(Icons.calendar_today_outlined, "Date", expense.createdAt?.split('T').first ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}