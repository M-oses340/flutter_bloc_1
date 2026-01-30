import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/products_bloc.dart';
import '../../bloc/products_event.dart';
import '../../bloc/products_state.dart';
import '../../data/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final int shopId;

  const EditProductScreen({super.key, required this.product, required this.shopId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;

  File? _newImageFile;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _buyingPriceController = TextEditingController(text: widget.product.buyingPrice.toString());
    _sellingPriceController = TextEditingController(text: widget.product.sellingPrice.toString());
    _quantityController = TextEditingController(text: widget.product.remainingQuantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickerActive) return; // Prevent "already_active" platform exception

    setState(() => _isPickerActive = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() => _newImageFile = File(image.path));
      }
    } finally {
      if (mounted) setState(() => _isPickerActive = false);
    }
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

    context.read<ProductBloc>().add(
      UpdateProductRequested(
        productId: widget.product.id,
        productData: updatedData,
        imageFile: _newImageFile,
        shopId: widget.shopId,
        usePut: false, // Defaulting to PATCH for partial updates
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Product", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Update Successful"), backgroundColor: Colors.teal),
            );
            Navigator.pop(context, true); // Return true to trigger refresh in Details Screen
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildInput(_nameController, "Product Name", Icons.inventory_2_outlined),
                _buildInput(_skuController, "SKU Number", Icons.qr_code_scanner_outlined),
                Row(
                  children: [
                    Expanded(child: _buildInput(_buyingPriceController, "Buying (KSh)", Icons.money_off, isNum: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput(_sellingPriceController, "Selling (KSh)", Icons.attach_money, isNum: true)),
                  ],
                ),
                _buildInput(_quantityController, "Stock Quantity", Icons.production_quantity_limits, isNum: true),
                const SizedBox(height: 32),
                _buildDoneButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_newImageFile != null)
                Image.file(_newImageFile!, fit: BoxFit.cover, width: double.infinity)
              else if (widget.product.productImage.isNotEmpty)
                Image.network(widget.product.productImage, fit: BoxFit.cover, width: double.infinity)
              else
                const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.teal),

              if (_isPickerActive)
                const CircularProgressIndicator(color: Colors.teal),
            ],
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
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onDonePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Done", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        );
      },
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
          prefixIcon: Icon(icon, color: Colors.teal),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }
}