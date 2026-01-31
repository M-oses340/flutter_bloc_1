import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // ✅ Uses the brand primary color (Teal) instead of hardcoded Blue
        Icon(
          Icons.lock_person,
          size: 80,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          "Omwa Shop Management",
          textAlign: TextAlign.center,
          // ✅ Uses headlineSmall for consistent, theme-aware scaling
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // Ensures black in light mode, white in dark
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Manage your business with ease",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant, // Muted secondary text
          ),
        ),
      ],
    );
  }
}