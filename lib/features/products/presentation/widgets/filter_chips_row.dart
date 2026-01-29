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
              selectedColor: const Color(0xFF00695C),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}