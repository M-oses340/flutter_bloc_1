import 'package:flutter/material.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';

class DeleteCategoryDialog extends StatefulWidget {
  final int categoryId;
  final int shopId;
  final String categoryName;
  final CategoryBloc categoryBloc;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryId,
    required this.shopId,
    required this.categoryName,
    required this.categoryBloc,
  });

  @override
  State<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<DeleteCategoryDialog> {
  bool _isDeleting = false;

  void _handleDelete() async {
    // 1. Capture the Navigator before the async gap
    final navigator = Navigator.of(context);

    setState(() => _isDeleting = true);

    widget.categoryBloc.add(
      DeleteCategoryRequested(
        categoryId: widget.categoryId,
        shopId: widget.shopId,
        categoryName: widget.categoryName,
      ),
    );

    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Check mounted property of the State object
    if (!mounted) return;

    // 3. Use the pre-captured navigator instead of 'context'
    navigator.pop(); // Close dialog
    navigator.pop(); // Go back to list
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Delete Category", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text("Are you sure you want to delete '${widget.categoryName}'?"),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            elevation: 0,
          ),
          onPressed: _isDeleting ? null : _handleDelete,
          child: _isDeleting
              ? SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(color: colorScheme.onError, strokeWidth: 2),
          )
              : const Text("Delete"),
        ),
      ],
    );
  }
}