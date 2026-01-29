import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
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


  Future<List<Category>> fetchCategories(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/categories/?shop_id=$shopId"),
        headers: await _getHeaders(),
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


  Future<Category> fetchCategoryById(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/categories/$categoryId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final Map<String, dynamic> categoryData = body['data'];
        return Category.fromJson(categoryData);
      } else {
        throw Exception("Failed to fetch category detail: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<Category> addCategory(String name, int shopId) async {
    try {
      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/categories/"),
        headers: await _getHeaders(),
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


  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse("$_cleanBaseUrl/categories/$categoryId/"),
        headers: await _getHeaders(),
      );

      // 204 means No Content (Success), 200 means OK
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception("Failed to delete category: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}