import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_service.dart';
import '../data/models/auth_response.dart';

class AuthRepository {
  // Existing login method...
  Future<AuthResponse> login(String email, String password) async {
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
      return AuthResponse.fromJson(data);
    } else {
      throw data['message'] ?? "Authentication failed";
    }
  }

  // NEW: Helper method for the PIN screen
  Future<AuthResponse> unlockWithPin(String email, String pin) async {
    // Since PIN = Password, we just call the login method
    return await login(email, pin);
  }
}