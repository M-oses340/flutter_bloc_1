import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final StorageService _storage = StorageService();

  // Helper to ensure the URL doesn't have a trailing slash conflict
  String get _cleanBaseUrl {
    String url = ApiConstants.baseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Consistent header management using the same PIN/Token logic
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.getToken();
    if (token == null) throw Exception("No token found");
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': ApiConstants.apiKey,
      'Authorization': 'Bearer $token',
    };
  }

  // GET: Fetch Customers for a shop
  Future<List<Customer>> fetchCustomers(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/customers/?shop_id=$shopId"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // Match your API structure: { "error": false, "data": [...] }
        if (body['error'] == false) {
          final List<dynamic> customerList = body['data'] ?? [];
          return customerList.map((json) => Customer.fromJson(json)).toList();
        }
        throw Exception(body['message'] ?? "Failed to fetch customers");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // POST: Create Customer
  Future<Customer> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await http.post(
        Uri.parse("$_cleanBaseUrl/customers/"),
        headers: await _getHeaders(),
        body: jsonEncode(customerData),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 201 || (response.statusCode == 200 && body['error'] == false)) {
        final dynamic data = body['data'] ?? body;
        return Customer.fromJson(data);
      } else {
        throw Exception(body['message'] ?? "Error ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // GET: Fetch Single Customer
  Future<Customer> fetchCustomerById(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse("$_cleanBaseUrl/customers/$customerId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic data = body['data'] ?? body;
        return Customer.fromJson(data);
      } else {
        throw Exception("Customer not found");
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE: Remove Customer
  Future<void> deleteCustomer(int customerId) async {
    try {
      final response = await http.delete(
        Uri.parse("$_cleanBaseUrl/customers/$customerId/"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception("Failed to delete customer (${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }
}