import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../widgets/product_image_picker.dart';
import '../../../../shared/widgets/custom_text_input.dart';

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
  File? _selectedImage;

  @override
  void dispose() {
    for (var controller in [_nameController, _skuController, _buyingPriceController, _sellingPriceController, _quantityController]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    final productData = {
      "name": _nameController.text.trim(),
      "sku": _skuController.text.trim(),
      "shop": widget.shopId,
      "buying_price": _buyingPriceController.text.trim(),
      "selling_price": _sellingPriceController.text.trim(),
      "remaining_quantity": _quantityController.text.trim(),
      "category": 1,
      "is_active": true,
    };

    context.read<ProductBloc>().add(AddProductRequested(
      productData: productData,
      imageFile: _selectedImage,
      shopId: widget.shopId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ✅ FIX: Use theme scaffold background
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Add New Product")),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAddSuccess) Navigator.pop(context, true);
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: colorScheme.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProductImagePicker(
                  selectedImage: _selectedImage,
                  onImageSelected: (file) => setState(() => _selectedImage = file),
                ),
                const SizedBox(height: 20),
                CustomTextInput(controller: _nameController, label: "Product Name", icon: Icons.shopping_bag_outlined),
                CustomTextInput(controller: _skuController, label: "SKU / Barcode", icon: Icons.qr_code_scanner),
                Row(
                  children: [
                    Expanded(child: CustomTextInput(controller: _buyingPriceController, label: "Buying Price", icon: Icons.download, isNum: true)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextInput(controller: _sellingPriceController, label: "Selling Price", icon: Icons.upload, isNum: true)),
                  ],
                ),
                CustomTextInput(controller: _quantityController, label: "Initial Stock Level", icon: Icons.inventory_2_outlined, isNum: true),
                const SizedBox(height: 32),
                _buildSaveButton(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final isAdding = state is ProductAdding;
        return SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // ✅ Uses your Teal (primary) and switches text to White (onPrimary)
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: isAdding ? null : _onSavePressed,
            child: isAdding
                ? SizedBox(
              height: 24, width: 24,
              child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
            )
                : const Text("Save Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }
}