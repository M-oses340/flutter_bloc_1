import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/storage_service.dart';
import '../../bloc/store_bloc.dart';
import '../../bloc/store_event.dart';
import '../../bloc/store_state.dart';
import '../widgets/store_form_widgets.dart';

class AddProductToStoreScreen extends StatefulWidget {
  const AddProductToStoreScreen({super.key});

  @override
  State<AddProductToStoreScreen> createState() => _AddProductToStoreScreenState();
}

class _AddProductToStoreScreenState extends State<AddProductToStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();

  final TextEditingController _buyingPriceController = TextEditingController(text: "0");
  final TextEditingController _sellingPriceController = TextEditingController(text: "0");
  final TextEditingController _quantityController = TextEditingController(text: "0");

  dynamic _selectedProductData;

  @override
  void dispose() {
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleRestock() async {
    final int? shopId = await _storage.getShopId();

    // ✅ FIX: "Don't use 'BuildContext's across async gaps"
    if (!mounted) return;

    if (_formKey.currentState!.validate() && _selectedProductData != null) {
      if (shopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No shop selected. Please login again.")),
        );
        return;
      }

      final stockData = {
        "product": _selectedProductData,
        "shop": shopId,
        "quantity": double.tryParse(_quantityController.text) ?? 0.0,
        "buying_price": double.tryParse(_buyingPriceController.text) ?? 0.0,
        "selling_price": double.tryParse(_sellingPriceController.text) ?? 0.0,
        "expiry_date": "2026-02-05",
      };

      context.read<StoreBloc>().add(AddStoreStockEvent(stockData));
      Navigator.pop(context);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedProductData = null;
      _buyingPriceController.text = "0";
      _sellingPriceController.text = "0";
      _quantityController.text = "0";
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Stock Entry", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormCard(
                    theme,
                    title: "Product Selection",
                    icon: Icons.inventory_2_outlined,
                    child: BlocBuilder<StoreBloc, StoreState>(
                      builder: (context, state) {
                        final productList = (state is StoreLoaded)
                            ? state.stocks.map((s) => s.product).toList()
                            : [];
                        return StoreProductSelector(
                          selectedValue: _selectedProductData,
                          products: productList,
                          onChanged: (val) => setState(() => _selectedProductData = val),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    theme,
                    title: "Pricing & Inventory",
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StoreInputField(
                                label: "Buying Price",
                                controller: _buyingPriceController,
                                prefixText: "KSh ", // ✅ Now defined
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StoreInputField(
                                label: "Selling Price",
                                controller: _sellingPriceController,
                                prefixText: "KSh ", // ✅ Now defined
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StoreInputField(
                          label: "Initial Quantity",
                          controller: _quantityController,
                          suffixText: "Units", // ✅ Now defined
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _handleRestock,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("CONFIRM STOCK ENTRY", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
        ),
        TextButton(
          onPressed: _resetForm,
          child: Text("Clear Form", style: TextStyle(color: colorScheme.outline)),
        ),
      ],
    );
  }
}

// ✅ Updated helper widget to handle the missing parameters
class StoreInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefixText;
  final String? suffixText;

  const StoreInputField({
    super.key,
    required this.label,
    required this.controller,
    this.prefixText,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}