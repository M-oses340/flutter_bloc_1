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
            color: isFilled ? colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: isFilled ? colorScheme.primary : colorScheme.outlineVariant,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}