import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();


  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserEmail = 'user_email';
  static const _keyActiveShopId = 'active_shop_id';
  static const _keyLastActive = 'last_active_time';
  static const _keyIsLocked = 'is_locked';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }


  Future<void> saveLastActiveTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _keyLastActive, value: now);
  }

  // NEW: Retrieve the time the user was last seen
  Future<int?> getLastActiveTime() async {
    String? time = await _storage.read(key: _keyLastActive);
    return time != null ? int.tryParse(time) : null;
  }

  Future<String?> getToken() async => await _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);
  Future<String?> getUserEmail() async => await _storage.read(key: _keyUserEmail);

  Future<void> saveShopId(int shopId) async =>
      await _storage.write(key: _keyActiveShopId, value: shopId.toString());

  Future<int?> getShopId() async {
    String? id = await _storage.read(key: _keyActiveShopId);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> setLockStatus(bool isLocked) async {
    await _storage.write(key: _keyIsLocked, value: isLocked.toString());
  }

  Future<bool> isLocked() async {
    String? value = await _storage.read(key: _keyIsLocked);
    return value == 'true';
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}