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

  // ✅ FIX: Changed from int? to dynamic to support String (new name) and int (existing ID)
  dynamic _selectedProductData;

  @override
  void dispose() {
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleRestock() async {
    // ✅ Ensure you use 'final' or 'int?' here to define the variable locally
    final int? shopId = await _storage.getShopId();

    // Now this debugPrint will work because shopId is defined in this scope
    debugPrint("--- Storage Check ---");
    debugPrint("Retrieved Shop ID: $shopId");

    if (_formKey.currentState!.validate() && _selectedProductData != null) {
      if (shopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No shop selected. Please login again.")),
        );
        return;
      }

      final stockData = {
        "product": _selectedProductData, // "mouse" (String) or ID (int)
        "shop": shopId,
        "quantity": double.tryParse(_quantityController.text) ?? 0.0,
        "buying_price": double.tryParse(_buyingPriceController.text) ?? 0.0,
        "selling_price": double.tryParse(_sellingPriceController.text) ?? 0.0,
        "expiry_date": "2026-02-02",
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
    final tealColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Add Product To Store",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        iconTheme: IconThemeData(color: tealColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StoreFormSectionTitle(title: "Product Selection *"),

              // ✅ FIX: Using BlocBuilder to get actual products for the selector
              BlocBuilder<StoreBloc, StoreState>(
                builder: (context, state) {
                  // Assuming your StoreState has a 'products' list
                  final productList = (state is StoreLoaded) ? state.stocks.map((s) => s.product).toList() : [];

                  return StoreProductSelector(
                    selectedValue: _selectedProductData,
                    products: productList,
                    onChanged: (val) {
                      setState(() {
                        _selectedProductData = val; // Accepts int or String
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
              const StoreFormSectionTitle(title: "Pricing Details"),
              Row(
                children: [
                  Expanded(
                    child: StoreInputField(
                      label: "Buying Price",
                      controller: _buyingPriceController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StoreInputField(
                      label: "Selling Price",
                      controller: _sellingPriceController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const StoreFormSectionTitle(title: "Inventory"),
              StoreInputField(
                label: "Initial Quantity",
                controller: _quantityController,
              ),

              const SizedBox(height: 40),
              _buildActionButtons(theme, tealColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, Color tealColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _handleRestock,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
                "CONFIRM & ADD",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: tealColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: tealColor.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
                "Clear Form",
                style: TextStyle(color: tealColor, fontWeight: FontWeight.w500)
            ),
          ),
        ),
      ],
    );
  }
}