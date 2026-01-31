import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filters = ["All", "In Stock", "Low Stock", "Out of Stock"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) onFilterSelected(filter);
              },

              selectedColor: colorScheme.primary,

              backgroundColor: colorScheme.surfaceContainer,

              labelStyle: TextStyle(

                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),


              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}