import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/shop_model.dart';

class ShopRepository {
  final StorageService storage;
  ShopRepository(this.storage);

  // Helper for Headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.getToken();
    return {
      "Content-Type": "application/json",
      "X-API-KEY": ApiConstants.apiKey,
      "Authorization": "Bearer $token",
    };
  }

  // 1. Fetch List of Shops
  Future<List<Shop>> fetchShops() async {
    final url = Uri.parse(ApiConstants.shopsEndpoint);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      try {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          rawList = decodedData['results'] ?? decodedData['data'] ?? [];
        }
        return rawList.map((item) => Shop.fromJson(item)).toList();
      } catch (e) {
        throw "Parsing Error: $e";
      }
    } else {
      throw "Server Error: ${response.statusCode}";
    }
  }

  // 2. Fetch Individual Shop Details
  Future<Shop> fetchShopDetails(int shopId) async {
    final url = Uri.parse("${ApiConstants.shopsEndpoint}$shopId/");
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body));
    } else {
      throw "Failed to load shop details (Status: ${response.statusCode})";
    }
  }

  // 3. Delete a Shop
  Future<void> deleteShop(int shopId) async {
    final url = Uri.parse("${ApiConstants.shopsEndpoint}$shopId/");
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw "Could not delete shop. Error: ${response.statusCode}";
    }
  }
}