import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final StorageService _storage = StorageService();

  // Helper to ensure the URL doesn't have a trailing slash conflict
  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Consistent header management
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.getToken();
    if (token == null) throw Exception("No token found");
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': ApiConstants.apiKey,
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all products for a specific shop
  Future<List<Product>> fetchProducts(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/products/?shop_id=$shopId"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> productList = body['data'] ?? [];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
  /// Add a new product to the database
  Future<Product> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/products/"),
        headers: await _getHeaders(),
        body: jsonEncode(productData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // Some APIs return the new object inside a 'data' key, others return it directly
        final dynamic data = body['data'] ?? body;
        return Product.fromJson(data);
      } else {
        // Log the body to see validation errors from your backend (e.g., "SKU already exists")
        throw Exception("Failed to add product: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId, int shopId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/products/by-category/$categoryId/shop/$shopId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> productList = body['data'] ?? [];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load products for category $categoryId");
      }
    } catch (e) {
      rethrow;
    }
  }
}