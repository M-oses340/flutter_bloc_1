import 'package:flutter/material.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_event.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryBloc categoryBloc;
  final int shopId;

  const AddCategoryDialog({
    super.key,
    required this.categoryBloc,
    required this.shopId,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  void _onSave() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    widget.categoryBloc.add(
      AddCategoryRequested(name: name, shopId: widget.shopId),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text("New Category"),
      // Standardize corners with the rest of your app's dialogs
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_isSaving,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: "Enter category name",
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          filled: true,
          // ✅ FIX: Uses tonal surface for the input background
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          // ✅ FIX: Use onSurfaceVariant for a secondary "Cancel" feel
          child: Text(
            "Cancel",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // ✅ FIX: Links to your global Primary Teal
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: colorScheme.onPrimary,
              strokeWidth: 2,
            ),
          )
              : const Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}