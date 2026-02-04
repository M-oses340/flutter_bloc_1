import 'dart:convert';
import 'package:flutter/material.dart';
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
  // inside StoreRepository class

// 🔍 1. Check if the product still exists in the main catalog
  Future<bool> checkProductExists(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/products/$productId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      // If 200 it exists; 404 means it's gone
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Future<void> transferStockToMain(int stockId, double quantity) async {
    final url = "$_cleanBaseUrl/store/transfer/$stockId/";


    final body = jsonEncode({
      "quantity": quantity,
      "confirm": true,
    });



    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: body,
      ).timeout(const Duration(seconds: 15));

      debugPrint('📥 [API RESPONSE] STATUS: ${response.statusCode}');
      debugPrint('📄 [API BODY]: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check for both HTTP status and the backend's internal error flag
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? "Unknown Backend Error");
        }
        // If we reach here, transfer was 100% successful!
        debugPrint('✅ Transfer Verified: ${responseData['message']}');
      } else {
        // Handle 400, 404, 500 etc.
        final errorMessage = responseData['message'] ?? responseData['error'] ?? response.body;
        throw Exception("Transfer failed (${response.statusCode}): $errorMessage");
      }
    } catch (e) {
      debugPrint('🚨 [API ERROR]: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> restoreProduct(StoreStock stock) async {
    final Map<String, dynamic> recoveryData = {
      "name": stock.productName,
      "sku": stock.productSku,
      "category": 1,
      "shop": await _storage.getShopId(),
      "buying_price": stock.buyingPrice,
      "selling_price": stock.sellingPrice,
    };
    return await createProduct(recoveryData);
  }

  Future<StoreStock> restockProduct(Map<String, dynamic> stockData) async {
    try {



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

        print("❌ Server Error Response: ${response.body}");
        throw Exception("Restock Failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("🚨 Connection Error: $e");
      rethrow;
    }
  }
}