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

      // FIX: Ensure there is a trailing slash before the '?'

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var shopId = prefs.getInt("shopId");
      final response = await http
          .get(
            Uri.parse("${ApiConstants.baseUrl}categories/?shop_id=$shopId"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        // Detailed log for 403
        print("⛔ 403 Forbidden: User does not have access to shop $shopId");
        throw Exception(
          "You don't have permission to view this shop's categories.",
        );
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
