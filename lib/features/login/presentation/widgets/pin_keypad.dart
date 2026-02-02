import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((n) => _buildNumberButton(context, n.toString())).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space for layout balance
            _buildNumberButton(context, "0"),
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: onBackspace,
                // Using primary color for the icon to match your teal theme
                icon: Icon(Icons.backspace_outlined, size: 28, color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => onKeyTap(text),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Uses cardColor from your AppTheme (White in Light, Dark Grey in Dark)
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.05 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface, // Automatically flips Black/White
            ),
          ),
        ),
      ),
    );
  }
}