import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_state.dart';
import '../screens/add_category_screen.dart'; // Ensure this points to your AddCategoryDialog

class CategoryAddButton extends StatelessWidget {
  final int shopId;

  const CategoryAddButton({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final bool isFetching = state is CategoryLoading;

        return FloatingActionButton(
          // ✅ FIX: Use primary for active, and a tonal surface variant for busy state
          backgroundColor: isFetching
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary,
          // ✅ FIX: Match icon/progress color to the background
          foregroundColor: isFetching
              ? colorScheme.onSurfaceVariant
              : colorScheme.onPrimary,
          onPressed: isFetching
              ? null
              : () {
            final bloc = context.read<CategoryBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AddCategoryDialog(
                categoryBloc: bloc,
                shopId: shopId,
              ),
            );
          },
          child: isFetching
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              // ✅ Progress indicator now adapts to the button's foreground color
              color: colorScheme.onSurfaceVariant,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.add),
        );
      },
    );
  }
}