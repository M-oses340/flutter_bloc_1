import 'package:flutter/material.dart';

class PinIndicator extends StatelessWidget {
  final int length;
  final int maxLength;

  const PinIndicator({
    super.key,
    required this.length,
    this.maxLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        bool isFilled = length > index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Uses primaryTeal for filled, transparent for empty
            color: isFilled ? colorScheme.primary : Colors.transparent,
            border: Border.all(
              // Uses primaryTeal for filled, outline color for empty
              color: isFilled ? colorScheme.primary : colorScheme.outlineVariant,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}