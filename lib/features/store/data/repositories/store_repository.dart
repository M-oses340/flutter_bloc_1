import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/store_stock.dart';

class StoreRepository {
  final StorageService _storage = StorageService();


  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }


  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.getToken();
    if (token == null) throw Exception("No token found");
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': ApiConstants.apiKey,
      'Authorization': 'Bearer $token',
    };
  }


  Future<List<StoreStock>> fetchStoreStocks() async {
    try {
      final int? shopId = await _storage.getShopId();
      if (shopId == null) throw Exception("No shop selected");

      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/store/list/?shop_id=$shopId"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);


        final List<dynamic> stockList = (body is Map && body.containsKey('data'))
            ? body['data']
            : body;

        return stockList.map((json) => StoreStock.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
  // Change 'String name' to 'Map<String, dynamic> data'
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/products/"),
        headers: await _getHeaders(),
        body: jsonEncode(data), // Now sending the full Map
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        return (body is Map && body.containsKey('data')) ? body['data'] : body;
      } else {
        throw Exception("Product creation failed: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<StoreStock> restockProduct(Map<String, dynamic> stockData) async {
    try {
      // 🚩 DEBUG: Print exactly what we are sending to the server
      print("📤 Repository Sending Payload: ${jsonEncode(stockData)}");


      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/store/restock/"),
        headers: await _getHeaders(),
        body: jsonEncode(stockData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        final dynamic data = (body is Map && body.containsKey('data'))
            ? body['data']
            : body;

        return StoreStock.fromJson(data);
      } else {
        // 🚩 DEBUG: If it fails, we want to see the specific server error
        print("❌ Server Error Response: ${response.body}");
        throw Exception("Restock Failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("🚨 Connection Error: $e");
      rethrow;
    }
  }
}