import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/make_sale_bloc.dart';
import '../../bloc/make_sale_state.dart';
import '../../bloc/make_sale_event.dart';
import '../widgets/cart_widget.dart';
import '../widgets/payment_method_selector.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  // Track which payment field is currently active for theming
  String _currentlyEditing = "MPESA";

  // Track amounts entered in the payment text fields
  final Map<String, double> _paymentAmounts = {
    "MPESA": 0.0,
    "CASH": 0.0,
    "CARD": 0.0,
  };

  // Helper to calculate total paid across all methods
  double get _totalPaid => _paymentAmounts.values.fold(0, (sum, item) => sum + item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),
      body: BlocBuilder<MakeSaleBloc, MakeSaleState>(
        builder: (context, state) {
          if (state is! MakeSaleLoaded || state.cartItems.isEmpty) {
            return const Center(child: Text("Cart is empty"));
          }

          // Deduplicate items for display rows
          final uniqueItems = state.cartItems.fold<Map<int, dynamic>>({}, (map, item) {
            map[item.id] = item;
            return map;
          }).values.toList();

          final double remaining = state.totalAmount - _totalPaid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cart Items (${state.cartItems.length})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),

                // 1. Product List (Deduplicated with quantity)
                ...uniqueItems.map((item) {
                  final qty = state.cartItems.where((i) => i.id == item.id).length;
                  return CartItemTile(
                    item: item,
                    quantity: qty,
                    onRemove: () => context.read<MakeSaleBloc>().add(RemoveProductFromCart(item.id)),
                    onIncrement: () => context.read<MakeSaleBloc>().add(IncrementCartItem(item.id)),
                    onDecrement: () => context.read<MakeSaleBloc>().add(DecrementCartItem(item.id)),
                  );
                }),

                const SizedBox(height: 24),

                // 2. Summary Card
                _buildSummaryCard(theme, state.totalAmount),

                const SizedBox(height: 12),

                // 3. Balance Alert (Shows only if balance remains)
                if (remaining > 0) _buildBalanceAlert(remaining),

                const SizedBox(height: 24),

                // 4. Payment Input Section
                PaymentMethodSelector(
                  payments: _paymentAmounts,
                  activeMethod: _currentlyEditing,
                  onAmountChanged: (method, amount) {
                    setState(() {
                      _paymentAmounts[method] = amount;
                      _currentlyEditing = method;
                    });
                  },
                ),

                const SizedBox(height: 12),
                Text(
                  "Total Paid: KSh ${_totalPaid.toStringAsFixed(2)}",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 24),
                _buildCustomerSection(theme),

                const SizedBox(height: 32),

                // 5. Complete Button (Enabled only if total is covered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _totalPaid >= state.totalAmount
                        ? () => _showPinVerification(context, state.totalAmount)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _totalPaid >= state.totalAmount
                          ? theme.colorScheme.primary
                          : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text("Complete Payment",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // UI Helpers
  Widget _buildSummaryCard(ThemeData theme, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("KSh ${total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildBalanceAlert(double remaining) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text("Still need KSh ${remaining.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Customer (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildField("Name", Icons.person_outline, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildField("Phone", Icons.phone_outlined, theme, isPhone: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String hint, IconData icon, ThemeData theme, {bool isPhone = false}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isPhone ? theme.colorScheme.primary : Colors.grey.shade300,
              width: isPhone ? 2 : 1
          ),
        ),
      ),
    );
  }

  void _showPinVerification(BuildContext context, double total) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirm Sale"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Verify authorization for KSh ${total.toStringAsFixed(2)}"),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Enter Login PIN",
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
            onPressed: () {
              // Final authorization using the login PIN
              Navigator.pop(dialogContext);
              // TODO: Add Bloc event to finalize sale
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}