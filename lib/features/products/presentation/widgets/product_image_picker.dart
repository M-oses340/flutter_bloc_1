import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImageSelected;

  const ProductImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 80,
    );

    if (image != null) {
      onImageSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(selectedImage!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.teal[300]),
            const SizedBox(height: 8),
            Text("Add Product Photo",
                style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}