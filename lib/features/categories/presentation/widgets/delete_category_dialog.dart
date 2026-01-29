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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Delete Category"),
      content: Text("Are you sure you want to delete '${widget.categoryName}'?"),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isDeleting
              ? null
              : () async {
            setState(() => _isDeleting = true);

            widget.categoryBloc.add(
              DeleteCategoryRequested(
                categoryId: widget.categoryId,
                shopId: widget.shopId,
                categoryName: widget.categoryName,
              ),
            );

            await Future.delayed(const Duration(milliseconds: 300));

            if (mounted) {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list
            }
          },
          child: _isDeleting
              ? const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}