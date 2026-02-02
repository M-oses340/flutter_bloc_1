import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // Unified save method for tokens
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  // Helper to save email for the PIN screen (Since you use the login PIN)
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: 'user_email', value: email);
  }

  Future<String?> getToken() async => await _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async => await _storage.read(key: 'refresh_token');
  Future<String?> getUserEmail() async => await _storage.read(key: 'user_email');

  Future<void> saveShopId(int shopId) async =>
      await _storage.write(key: 'active_shop_id', value: shopId.toString());

  Future<int?> getShopId() async {
    String? id = await _storage.read(key: 'active_shop_id');
    return id != null ? int.tryParse(id) : null;
  }

  // Clear all sensitive data on logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}