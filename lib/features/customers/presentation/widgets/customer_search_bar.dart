import 'package:flutter/material.dart';

class CustomerSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const CustomerSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search customers...",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Using a subtle border to match your screenshot
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}