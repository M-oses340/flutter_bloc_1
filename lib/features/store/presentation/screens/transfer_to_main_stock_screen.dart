import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/store_bloc.dart';
import '../../bloc/store_event.dart';
import '../../bloc/store_state.dart';
import '../../data/models/store_stock.dart';
import '../widgets/transfer_widgets.dart';

class TransferToMainStockScreen extends StatefulWidget {
  final StoreStock stock;
  const TransferToMainStockScreen({super.key, required this.stock});

  @override
  State<TransferToMainStockScreen> createState() => _TransferToMainStockScreenState();
}

class _TransferToMainStockScreenState extends State<TransferToMainStockScreen> {
  final TextEditingController _quantityController = TextEditingController(text: "0.00");
  double _transferQuantity = 0.0;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() {
      setState(() => _transferQuantity = double.tryParse(_quantityController.text) ?? 0.0);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<StoreBloc, StoreState>(
        listener: (context, state) {
          if (state is StoreLoading) {
            _showLoadingDialog(context);
          }


          if (state is StoreTransferSuccess) {
            Navigator.of(context).pop();
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.secondary,
              ),
            );
          }

          if (state is StoreError) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: colorScheme.error),
            );
          }
        },
      child: Scaffold(

        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        appBar: AppBar(
          title: const Text("Transfer to Main Stock"),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TransferProductHeader(stock: widget.stock),
              const SizedBox(height: 24),

              _buildInputCard(theme),

              const SizedBox(height: 24),

              TransferSummaryCard(
                quantity: _transferQuantity,
                remaining: widget.stock.remainingQuantity - _transferQuantity,
                totalValue: _transferQuantity * widget.stock.buyingPrice,
              ),

              const SizedBox(height: 32),
              _buildConfirmButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: "Quantity to Transfer",
          labelStyle: TextStyle(color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () {
          // 🛡️ Logic Validations
          if (_transferQuantity <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter a valid quantity")),
            );
            return;
          }

          if (_transferQuantity > widget.stock.remainingQuantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Insufficient stock available")),
            );
            return;
          }

          // 🚀 Triggering the Bloc with the same PIN/Auth context
          context.read<StoreBloc>().add(TransferStockEvent(
            stock: widget.stock,
            quantity: _transferQuantity,
          ));
        },
        child: const Text(
          "Confirm Transfer",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}