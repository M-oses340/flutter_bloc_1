import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final Function(String email, String password) onLogin;
  // ✅ Added this to share the PIN state with the LoginScreen
  final TextEditingController pinController;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.pinController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  // 🗑️ _pass controller removed because we use widget.pinController now
  bool _obscureText = true;

  @override
  void dispose() {
    _email.dispose();
    // 💡 Note: We do NOT dispose widget.pinController here because
    // it belongs to the LoginScreen.
    super.dispose();
  }

  void _handleLogin() {
    final emailValue = _email.text.trim();
    final pinValue = widget.pinController.text.trim();

    if (emailValue.isEmpty || pinValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and PIN")),
      );
      return;
    }

    // Pass data up to the LoginScreen's Bloc call
    widget.onLogin(emailValue, pinValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildTextField(
          context: context,
          controller: _email,
          label: "Email",
          icon: Icons.email_outlined,
          enabled: !widget.isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          context: context,
          controller: widget.pinController, // ✅ Now using the shared controller
          label: "Security PIN",
          icon: Icons.lock_outline,
          isPassword: true,
          enabled: !widget.isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: widget.isLoading
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const StadiumBorder(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: _handleLogin,
            child: const Text(
              "LOGIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      maxLength: isPassword ? 4 : null,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: isPassword ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: colorScheme.primary),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}