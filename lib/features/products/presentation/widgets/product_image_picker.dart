import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? initialImageUrl;
  final Function(File) onImageSelected;

  const ProductImagePicker({
    super.key,
    this.selectedImage,
    this.initialImageUrl,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          // ✅ FIX: Uses a tonal surface color that darkens for Dark Mode
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // ✅ FIX: Uses theme's outline variant instead of hardcoded grey
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildImageContent(colorScheme),
        ),
      ),
    );
  }

  Widget _buildImageContent(ColorScheme colorScheme) {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity);
    } else if (initialImageUrl != null && initialImageUrl!.isNotEmpty) {
      return Image.network(
        initialImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 40,
          // ✅ FIX: Uses theme's primary (Teal)
          color: colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          "Tap to upload product image",
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}