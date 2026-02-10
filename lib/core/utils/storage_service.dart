import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  // 1. Create a private constructor
  StorageService._internal();

  // 2. The single instance of the class
  static final StorageService _instance = StorageService._internal();

  // 3. Factory constructor to return the same instance every time
  factory StorageService() => _instance;

  // 4. Initialize Secure Storage with modern Android options
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // We explicitly leave out the deprecated 'encryptedSharedPreferences'
      // The library now handles modern encryption automatically.
      resetOnError: true, // Useful if the keystore becomes corrupted
    ),
  );

  // --- Keys ---
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserEmail = 'user_email';
  static const _keyActiveShopId = 'active_shop_id';
  static const _keyLastActive = 'last_active_time';
  static const _keyIsLocked = 'is_locked';
  static const _keyUserPin = 'user_pin';

  // --- Methods ---

  /// Saves both access and refresh tokens
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
    debugPrint('💾 [Storage] Tokens saved successfully.');
  }

  /// Retrieves the access token for API calls
  Future<String?> getToken() async {
    final token = await _storage.read(key: _keyAccessToken);
    debugPrint('🔑 [Storage] Reading Access Token: ${token != null ? "Found" : "NULL"}');
    return token;
  }

  /// Saves the user email for persistent identification
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async => await _storage.read(key: _keyUserEmail);

  /// Saves the 4-digit PIN (Used for local login validation)
  Future<void> saveUserPin(String pin) async {
    await _storage.write(key: _keyUserPin, value: pin);
    debugPrint('🔐 [Storage] User PIN saved locally.');
  }

  Future<String?> getUserPin() async => await _storage.read(key: _keyUserPin);

  /// Shop ID Management
  Future<void> saveShopId(int shopId) async =>
      await _storage.write(key: _keyActiveShopId, value: shopId.toString());

  Future<int?> getShopId() async {
    String? id = await _storage.read(key: _keyActiveShopId);
    return id != null ? int.tryParse(id) : null;
  }

  /// Session Timing
  Future<void> saveLastActiveTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _keyLastActive, value: now);
  }

  Future<int?> getLastActiveTime() async {
    String? time = await _storage.read(key: _keyLastActive);
    return time != null ? int.tryParse(time) : null;
  }

  /// Lock Status
  Future<void> setLockStatus(bool isLocked) async {
    await _storage.write(key: _keyIsLocked, value: isLocked.toString());
  }

  Future<bool> isLocked() async {
    String? value = await _storage.read(key: _keyIsLocked);
    return value == 'true';
  }

  /// Clears all data on logout
  Future<void> logout() async {
    await _storage.deleteAll();
    debugPrint('🚪 [Storage] All data cleared.');
  }
}