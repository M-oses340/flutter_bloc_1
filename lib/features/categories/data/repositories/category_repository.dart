import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final StorageService _storage = StorageService();

  // Helper to centralize URL cleaning
  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // --- FETCH ALL ---
  Future<List<Category>> fetchCategories(int shopId) async {
    try {
      final String? token = await _storage.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/categories/?shop_id=$shopId"),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> categoryList = body['data'] ?? [];
        return categoryList.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- FETCH SPECIFIC CATEGORY ---
  Future<Category> fetchCategoryById(int categoryId) async {
    try {
      final String? token = await _storage.getToken();
      if (token == null) throw Exception("No token found");

      print("📡 Fetching Category Detail for ID: $categoryId");

      // Appends the ID to the path: /categories/2/
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/categories/$categoryId/"),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("📥 Single Category Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // As per your provided JSON structure, the data is inside the "data" key
        final Map<String, dynamic> categoryData = body['data'];

        return Category.fromJson(categoryData);
      } else {
        throw Exception("Failed to fetch category detail: ${response.statusCode}");
      }
    } catch (e) {
      print("🛑 Single Category Repo Error: $e");
      rethrow;
    }
  }

  // --- ADD CATEGORY ---
  Future<Category> addCategory(String name, int shopId) async {
    try {
      final String? token = await _storage.getToken();

      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/categories/"),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": name,
          "shop": shopId,
          "is_active": true
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final Map<String, dynamic> categoryData = body.containsKey('data')
            ? body['data']
            : body;
        return Category.fromJson(categoryData);
      } else {
        throw Exception("Failed to add category: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}