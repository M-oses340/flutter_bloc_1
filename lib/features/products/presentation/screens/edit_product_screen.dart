import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_image_picker.dart';
import '../../../../shared/widgets/custom_text_input.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final int shopId;

  const EditProductScreen({super.key, required this.product, required this.shopId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers initialized directly in the field
  late final _nameController = TextEditingController(text: widget.product.name);
  late final _skuController = TextEditingController(text: widget.product.sku);
  late final _buyingPriceController = TextEditingController(text: widget.product.buyingPrice.toString());
  late final _sellingPriceController = TextEditingController(text: widget.product.sellingPrice.toString());
  late final _quantityController = TextEditingController(text: widget.product.remainingQuantity.toString());

  File? _newImageFile;

  @override
  void dispose() {
    for (var c in [_nameController, _skuController, _buyingPriceController, _sellingPriceController, _quantityController]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onDonePressed() {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      "name": _nameController.text.trim(),
      "sku": _skuController.text.trim(),
      "buying_price": _buyingPriceController.text,
      "selling_price": _sellingPriceController.text,
      "remaining_quantity": _quantityController.text,
      "category": widget.product.categoryId,
      "shop": widget.shopId,
    };

    context.read<ProductBloc>().add(UpdateProductRequested(
      productId: widget.product.id,
      productData: updatedData,
      imageFile: _newImageFile,
      shopId: widget.shopId,
      usePut: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Product")),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAddSuccess) {
            Navigator.pop(context, true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProductImagePicker(
                  selectedImage: _newImageFile,
                  initialImageUrl: widget.product.productImage,
                  onImageSelected: (file) => setState(() => _newImageFile = file),
                ),
                const SizedBox(height: 24),
                CustomTextInput(controller: _nameController, label: "Product Name", icon: Icons.inventory_2_outlined),
                CustomTextInput(controller: _skuController, label: "SKU Number", icon: Icons.qr_code_scanner_outlined),
                Row(
                  children: [
                    Expanded(child: CustomTextInput(controller: _buyingPriceController, label: "Buying (KSh)", icon: Icons.money_off, isNum: true)),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextInput(controller: _sellingPriceController, label: "Selling (KSh)", icon: Icons.attach_money, isNum: true)),
                  ],
                ),
                CustomTextInput(controller: _quantityController, label: "Stock Quantity", icon: Icons.production_quantity_limits, isNum: true),
                const SizedBox(height: 32),
                _buildDoneButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final isLoading = state is ProductAdding;
        return SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onDonePressed,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}