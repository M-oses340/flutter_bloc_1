import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final StorageService _storage = StorageService();

  Future<List<Category>> fetchCategories(int shopId) async {
    try {
      final String? token = await _storage.getToken();
      if (token == null) throw Exception("No token found");

      // 1. Clean the Base URL to avoid double slashes
      String cleanBaseUrl = ApiConstants.baseUrl;
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }

      print("📡 Fetching Categories for Shop ID: $shopId");

      final response = await http.get(
        Uri.parse("$cleanBaseUrl/categories/?shop_id=$shopId"),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("📥 Category Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // 2. Parse the body as a Map first
        final Map<String, dynamic> body = jsonDecode(response.body);

        // 3. Extract the list from the "data" key
        final List<dynamic> categoryList = body['data'] ?? [];

        return categoryList.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        print("⛔ 403 Forbidden: User does not have access to shop $shopId");
        throw Exception("Access Denied: You aren't assigned to this shop.");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🛑 Category Repo Error: $e");
      rethrow; // Better to rethrow so the Bloc can catch the specific error
    }
  }
}