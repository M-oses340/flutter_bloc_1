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

    // Send the event to the Bloc
    widget.categoryBloc.add(
      AddCategoryRequested(name: name, shopId: widget.shopId),
    );

    // Give the UI a moment to show the spinner before closing
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Category"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_isSaving,
        decoration: const InputDecoration(
          hintText: "Enter category name",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            disabledBackgroundColor: Colors.teal.withValues(alpha: 0.6),
          ),
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text("Create", style: TextStyle(color: Colors.white)),
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