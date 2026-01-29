import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // Tokens
  Future<void> saveToken(String token) async =>
      await _storage.write(key: 'access_token', value: token);

  Future<String?> getToken() async =>
      await _storage.read(key: 'access_token');

  // Shop ID (Stored as String, converted from Int)
  Future<void> saveShopId(int shopId) async =>
      await _storage.write(key: 'active_shop_id', value: shopId.toString());

  Future<int?> getShopId() async {
    String? id = await _storage.read(key: 'active_shop_id');
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'active_shop_id');
  }
}