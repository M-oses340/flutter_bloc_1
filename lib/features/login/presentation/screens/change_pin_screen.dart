import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import 'login_screen.dart';

class ChangePinScreen extends StatefulWidget {
  final bool isForcedReset;
  final String? token; // ✅ Token passed from successful login

  const ChangePinScreen({super.key, this.isForcedReset = false, this.token});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final StorageService _storage = StorageService();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePin() async {
    final newPin = _newPinController.text.trim();

    // 1. Validation
    if (newPin.length < 4 || newPin != _confirmPinController.text.trim()) {
      _showSnackBar("PINs must match and be 4 digits", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Token Resolution
      final String? activeToken = widget.token ?? context.read<AuthRepository>().activeSessionToken;

      if (activeToken == null) {
        debugPrint('❌ [ChangePin] No valid token found.');
        _showSnackBar("Session expired. Please login again.", isError: true);
        _goToLogin();
        return;
      }

      debugPrint('📡 [ChangePin] Sending PUT request to update PIN...');

      // 3. API Call
      final response = await context.read<AuthRepository>().changePassword(
        oldPassword: "3326",
        newPassword: newPin,
        token: activeToken,
      );

      if (!response.error) {
        debugPrint('✅ [ChangePin] Success! Syncing local storage...');

        // 4. Update local PIN storage so "Unlock" works later
        await _storage.saveUserPin(newPin);

        if (mounted) {
          _showSnackBar("PIN updated successfully!", isError: false);

          // 🚀 DIRECT NAVIGATION: Tell the app we are logged in.
          // This will trigger your main.dart BlocBuilder to show the Shop/Home screen.
          context.read<AuthBloc>().add(UserLoggedIn());
        }
      } else {
        debugPrint('❌ [ChangePin] API Error: ${response.message}');
        _showSnackBar(response.message, isError: true);
      }
    } catch (e) {
      debugPrint('💥 [ChangePin] Exception: $e');
      _showSnackBar("Connection error. Try again.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Personal PIN"),
        automaticallyImplyLeading: !widget.isForcedReset,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Your account is using a temporary PIN.\nPlease create a new 4-digit security PIN.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _newPinController,
              obscureText: true,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: const InputDecoration(
                labelText: "New PIN",
                hintText: "••••",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: const InputDecoration(
                labelText: "Confirm PIN",
                hintText: "••••",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleUpdatePin,
                child: const Text(
                  "SAVE & CONTINUE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}