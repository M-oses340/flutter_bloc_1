import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/sale_product_model.dart';

class MakeSaleRepository {
  final StorageService _storage = StorageService();


  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Matches your security pattern (Token + API Key)
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.getToken();
    if (token == null) throw Exception("No token found");
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': ApiConstants.apiKey,
      'Authorization': 'Bearer $token',
    };
  }


  Future<List<SaleProduct>> fetchSaleProducts(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/products/?shop_id=$shopId"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        // Matches your pattern of accessing the 'data' key
        final List<dynamic> productList = body['data'] ?? [];
        return productList.map((json) => SaleProduct.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {

      rethrow;
    }
  }
}