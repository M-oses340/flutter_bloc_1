import 'package:flutter/material.dart';

class SnackBarUtils {
  // ✅ FIX: Uses Primary (Teal) for success
  static void showSuccess(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
        context,
        message,
        colorScheme.primary,
        colorScheme.onPrimary,
        Icons.check_circle_outline
    );
  }

  // ✅ FIX: Uses Semantic Error color
  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
        context,
        message,
        colorScheme.error,
        colorScheme.onError,
        Icons.error_outline
    );
  }

  // ✅ FIX: Uses Tertiary or Secondary for Info
  static void showInfo(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
        context,
        message,
        colorScheme.tertiary,
        colorScheme.onTertiary,
        Icons.info_outline
    );
  }

  static void _show(
      BuildContext context,
      String message,
      Color bgColor,
      Color textColor,
      IconData icon
      ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}