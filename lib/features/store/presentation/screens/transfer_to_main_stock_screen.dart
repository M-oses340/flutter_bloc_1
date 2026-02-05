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
      setState(() {
        _transferQuantity = double.tryParse(_quantityController.text) ?? 0.0;
      });
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
          // Pop the loading dialog
          Navigator.of(context).pop();
          // Pop the transfer screen
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (state is StoreError) {
          // Close loading dialog if open
          if (Navigator.canPop(context)) Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Stock Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.primaryContainer.withValues(alpha: 0.15),
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 📦 Product Identity Card
                  _buildShadowWrapper(
                    child: TransferProductHeader(stock: widget.stock),
                  ),

                  const SizedBox(height: 20),

                  // 🔢 Quantity Input Card
                  _buildInputCard(theme),

                  const SizedBox(height: 20),

                  // 📊 Calculation Summary Card
                  _buildShadowWrapper(
                    child: TransferSummaryCard(
                      quantity: _transferQuantity,
                      remaining: widget.stock.remainingQuantity - _transferQuantity,
                      totalValue: _transferQuantity * widget.stock.buyingPrice,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔘 Action Button
                  _buildConfirmButton(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildShadowWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            "Quantity to Transfer",
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              suffixText: "Units",
              suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.bold
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const StadiumBorder(),
          elevation: 8,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
        ),
        onPressed: () {
          if (_transferQuantity <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter a valid quantity")),
            );
            return;
          }

          if (_transferQuantity > widget.stock.remainingQuantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Transfer exceeds available stock")),
            );
            return;
          }

          // Triggering the migration via the Bloc
          context.read<StoreBloc>().add(TransferStockEvent(
            stock: widget.stock,
            quantity: _transferQuantity,
          ));
        },
        child: const Text(
          "Confirm Transfer",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 5,
            ),
          ),
        ),
      ),
    );
  }
}