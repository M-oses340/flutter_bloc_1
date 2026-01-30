import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
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

  Future<Product> addProduct(Map<String, dynamic> productData, File? imageFile) async {
    try {
      final url = Uri.parse("$_cleanBaseUrl/products/");


      final request = http.MultipartRequest('POST', url);


      final headers = await _getHeaders();
      request.headers.addAll(headers);


      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });


      if (imageFile != null) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();

        final multipartFile = http.MultipartFile(
          'product_image',
          stream,
          length,
          filename: basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }


      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic data = body['data'] ?? body;
        return Product.fromJson(data);
      } else {

        throw Exception("Error ${response.statusCode}: ${response.body}");
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

  Future<Product> fetchProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/products/$productId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic data = body['data'] ?? body;
        return Product.fromJson(data);
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct({
    required int productId,
    required Map<String, dynamic> productData,
    File? imageFile,
    bool isFullUpdate = false, // true for PUT, false for PATCH
  }) async {
    try {
      final url = Uri.parse("$_cleanBaseUrl/products/$productId/");

      // Choose method based on your requirement
      final method = isFullUpdate ? 'PUT' : 'PATCH';
      final request = http.MultipartRequest(method, url);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      productData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image if a new one was selected
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'product_image',
          imageFile.path,
          filename: basename(imageFile.path),
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode >= 200 && response.statusCode < 300) {


        if (response.statusCode == 204 || response.body.isEmpty) {

          return Product.fromJson(productData);
        }

        return Product.fromJson(jsonDecode(response.body));
      } else {

        throw Exception("Update failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}