import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/shop_model.dart';

class ShopRepository {
  final StorageService storage;
  ShopRepository(this.storage);

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.getToken();
    return {
      "Content-Type": "application/json",
      "X-API-KEY": ApiConstants.apiKey,
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Shop>> fetchShops() async {
    // 1. Ensure baseUrl ends with a slash for Uri.resolve to work
    String baseUrl = ApiConstants.baseUrl;
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';

    // 2. Resolve 'shops/' against the base URL
    final url = Uri.parse(baseUrl).resolve('shops/');

    print("📡 Requesting Shops from: $url");

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      List<dynamic> rawList = (decodedData is List)
          ? decodedData
          : (decodedData['results'] ?? decodedData['data'] ?? []);
      return rawList.map((item) => Shop.fromJson(item)).toList();
    } else {
      print("❌ Shop Error ${response.statusCode}: ${response.body}");
      throw "Server Error: ${response.statusCode}";
    }
  }

  Future<Shop> fetchShopDetails(int shopId) async {
    String baseUrl = ApiConstants.baseUrl;
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';

    // Resolves to base_url/shops/ID/
    final url = Uri.parse(baseUrl).resolve('shops/$shopId/');

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body));
    } else {
      throw "Failed to load shop details: ${response.statusCode}";
    }
  }
}