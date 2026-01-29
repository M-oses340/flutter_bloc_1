import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';

class AddProductScreen extends StatefulWidget {
  final int shopId;
  const AddProductScreen({super.key, required this.shopId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  void _onSavePressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final productData = {
      "name": _nameController.text.trim(),
      "sku": _skuController.text.trim(),
      "shop": widget.shopId,
      "buying_price": double.parse(_buyingPriceController.text),
      "selling_price": double.parse(_sellingPriceController.text),
      "remaining_quantity": double.parse(_quantityController.text),
      "category": 1,
      "is_active": true,
    };

    context.read<ProductBloc>().add(
        AddProductRequested(productData: productData, shopId: widget.shopId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Product", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        // Use listenWhen to react only to Success or Error for this screen
        listenWhen: (previous, current) => current is ProductAddSuccess || current is ProductError,
        listener: (context, state) {
          if (state is ProductAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product created successfully"), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput(_nameController, "Product Name", Icons.shopping_bag_outlined),
                _buildInput(_skuController, "SKU / Barcode", Icons.qr_code_scanner),
                Row(
                  children: [
                    Expanded(child: _buildInput(_buyingPriceController, "Buying Price", Icons.download, isNum: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(_sellingPriceController, "Selling Price", Icons.upload, isNum: true)),
                  ],
                ),
                _buildInput(_quantityController, "Initial Stock Level", Icons.inventory_2_outlined, isNum: true),
                const SizedBox(height: 32),

                // Only build the button part based on state
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    final isAdding = state is ProductAdding;
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isAdding ? null : () => _onSavePressed(context),
                        child: isAdding
                            ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                            : const Text("Save Product", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal, size: 22),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }
}