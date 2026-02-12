import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final Map<String, double> payments;
  final Function(String, double) onAmountChanged;
  final String activeMethod;

  const PaymentMethodSelector({
    super.key,
    required this.payments,
    required this.onAmountChanged,
    required this.activeMethod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final methods = ["MPESA", "CASH", "CARD"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Methods", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: methods.map((m) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildAmountField(m, theme),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountField(String label, ThemeData theme) {
    final bool isSelected = activeMethod == label;

    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (val) => onAmountChanged(label, double.tryParse(val) ?? 0.0),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isSelected ? theme.colorScheme.primary : Colors.grey,
        ),
        hintText: "0.00",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}