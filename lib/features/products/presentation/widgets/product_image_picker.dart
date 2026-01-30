import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? initialImageUrl; // Added for Edit mode
  final Function(File) onImageSelected;

  const ProductImagePicker({
    super.key,
    this.selectedImage,
    this.initialImageUrl,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (image != null) onImageSelected(File(image.path));
      },
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
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity);
    } else if (initialImageUrl != null && initialImageUrl!.isNotEmpty) {
      return Image.network(initialImageUrl!, fit: BoxFit.cover, width: double.infinity);
    }
    return const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.teal);
  }
}