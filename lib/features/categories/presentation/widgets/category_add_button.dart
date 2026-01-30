import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category_bloc.dart';
import '../../bloc/category_state.dart';
import 'add_category_screen.dart';

class CategoryAddButton extends StatelessWidget {
  final int shopId;

  const CategoryAddButton({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final bool isFetching = state is CategoryLoading;

        return FloatingActionButton(
          backgroundColor: isFetching ? Colors.grey : Colors.teal,
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
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }
}