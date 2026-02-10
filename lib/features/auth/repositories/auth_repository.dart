import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../data/models/auth_response.dart';

class AuthRepository {
  final StorageService _storage = StorageService();

  // Memory cache for the current session
  String? _activeSessionToken;

  /// Returns the token captured during the most recent login or unlock
  String? get activeSessionToken => _activeSessionToken;

  /// Standard Email/Password (or PIN) Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      debugPrint('📡 [AuthRepo] Attempting login for: $email');

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}auth/v1/auth/login/"),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": ApiConstants.apiKey,
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authRes = AuthResponse.fromJson(data);

        // 🔑 Capture tokens from the response
        final String? access = authRes.data?.accessToken;
        final String? refresh = authRes.data?.refreshToken;

        if (access != null && refresh != null) {
          _activeSessionToken = access;

          // ✅ PERSISTENCE: Save tokens and email to disk immediately
          // This allows ShopRepository to find the token on the next screen
          await _storage.saveTokens(access: access, refresh: refresh);
          await _storage.saveUserEmail(email);

          debugPrint('💾 [AuthRepo] Tokens and Email persisted to Storage.');
        }

        debugPrint('✅ [AuthRepo] Login success. Token captured: ${_activeSessionToken != null}');
        return authRes;
      } else {
        debugPrint('❌ [AuthRepo] Login rejected: ${data['message']}');
        throw data['message'] ?? "Authentication failed";
      }
    } catch (e) {
      debugPrint('💥 [AuthRepo] Login Exception: $e');
      rethrow;
    }
  }

  /// Unlock with PIN (Alias for login)
  Future<AuthResponse> unlockWithPin(String email, String pin) async {
    return await login(email, pin);
  }

  /// ✅ Change Password / PIN
  /// Works for initial system reset (3326) and manual user updates
  Future<AuthResponse> changePassword({
    required String oldPassword, // Now dynamic! Pass "3326" for reset flow
    required String newPassword,
    required String token,
  }) async {
    try {
      // Use the provided token, fall back to memory, or empty string
      final String effectiveToken = token.isNotEmpty ? token : (_activeSessionToken ?? "");

      debugPrint('📡 [AuthRepo] Requesting PIN update...');

      final response = await http.put(
        Uri.parse(ApiConstants.changePassword),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $effectiveToken",
          "X-API-KEY": ApiConstants.apiKey,
        },
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [AuthRepo] PIN updated successfully on server.');

        // ✅ SYNC: Update the local PIN so "Unlock" matches the new server PIN
        await _storage.saveUserPin(newPassword);

        return AuthResponse.fromJson(data);
      } else {
        String errorMsg = data['message'] ?? data['detail'] ?? "Update failed";
        debugPrint('❌ [AuthRepo] Server rejected update: $errorMsg');
        return AuthResponse(error: true, message: errorMsg);
      }
    } catch (e) {
      debugPrint('💥 [AuthRepo] Change PIN Exception: $e');
      return AuthResponse(
        error: true,
        message: "An unexpected error occurred: $e",
      );
    }
  }

  /// Clear the session on logout
  void clearSession() {
    _activeSessionToken = null;
    _storage.logout(); // Clears SecureStorage/Disk
    debugPrint('🧼 [AuthRepo] Session token cleared from memory and storage.');
  }
}